// 设置docker的镜像版本后面增加时间信息，保证k8s的pod正常升级替换，否则，同版本的docker镜像版本需要手动删除pod节点才能正常更新
import java.text.SimpleDateFormat
def dateFormat = new SimpleDateFormat("yyyyMMddHHmmss")
def date = new Date()
// groovy中，局部变量前面加def，全局变量前面不需要加声明
dayTime = dateFormat.format(date)

pipeline {

    agent {
        label 'go'
    }

    environment {
        // 您 Docker Hub 仓库的地址
        REGISTRY = 'docker.io'
        // 您的 Docker Hub 用户名
        DOCKERHUB_USERNAME = 'samge'
        // Docker 镜像名称
        APP_NAME = "devops-go-sample"
        // Docker 镜像版本
        APP_VERSION = "v1-${dayTime}"
        // Docker 镜像名称:版本
        APP_NAME_FULL = "${APP_NAME}${APP_VERSION}"
        // 'docker-hub' 是您在 KubeSphere 用 Docker Hub 访问令牌创建的凭证 ID
        DOCKERHUB_CREDENTIAL = credentials('docker-hub')
        // git仓库登录的凭证
        GIT_CREDENTIAL = credentials('gitlab-qz')
        // 您在 KubeSphere 创建的 kubeconfig 凭证 ID
        KUBECONFIG_CREDENTIAL_ID = 'kubeconfig-info'
        // 您在 KubeSphere 创建的项目名称，不是 DevOps 项目名称
        PROJECT_NAME = 'test'
    }

    stages {

        // 登录docker阶段
        stage ('docker login') {
            steps {
                container ('go') {
                    sh 'echo $DOCKERHUB_CREDENTIAL_PSW | docker login -u $DOCKERHUB_CREDENTIAL_USR --password-stdin'
                }
            }
        }

        // 拉取git代码 + 编译docker镜像 + push docker镜像阶段
        stage ('build & push') {
            steps {
                container ('go') {
                    sh 'git config --global http.proxy "http://192.168.3.169:7890" && git config --global https.proxy "https://192.168.3.169:7890"'
                    sh 'git clone https://$GIT_CREDENTIAL_USR:$GIT_CREDENTIAL_PSW@gps.qianzhan.com/shaochengbao/devops-go-sample.git'
                    sh 'cd devops-go-sample && docker build -t $REGISTRY/$DOCKERHUB_USERNAME/$APP_NAME_FULL .'
                    sh 'docker push $REGISTRY/$DOCKERHUB_USERNAME/$APP_NAME_FULL'
                }
            }
        }

        // 部署k8s阶段
        stage ('deploy app') {
            steps {
                container ('go') {
                    withCredentials ([
                        kubeconfigFile (
                            credentialsId: env.KUBECONFIG_CREDENTIAL_ID,
                            variable: 'KUBECONFIG'
                        )
                    ]) {
                        sh 'envsubst < devops-go-sample/manifest/deploy.yaml | kubectl apply -f -'
                    }
                }
            }
        }

        // 清理阶段，这个阶段不管前面步骤成功还是失败都需要执行清理
        stage ('clean') {
            steps {
                container ('go') {
                    // 清理本地docker镜像
                    sh 'docker rmi $REGISTRY/$DOCKERHUB_USERNAME/$APP_NAME_FULL'

                    sh 'echo "部署完毕后，在debug模式下删除远程的docker镜像，避免镜像杂乱（正常应该在内网搭建docker环境进行开发测试）"'
                    sh 'curl -X DELETE https://hub.docker.com/v2/repositories/$DOCKERHUB_USERNAME/$APP_NAME/tags/$APP_VERSION/'

                    // 执行 docker logout命令清除缓存的docker登录信息：https://docs.docker.com/engine/reference/commandline/login/#credentials-store
                    sh 'docker logout'
                }
            }
        }
    }
}
