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
        APP_NAME = 'devops-go-sample:v1'
        // 'dockerhubid' 是您在 KubeSphere 用 Docker Hub 访问令牌创建的凭证 ID
        DOCKERHUB_CREDENTIAL = credentials('docker-hub')
        // 您在 KubeSphere 创建的 kubeconfig 凭证 ID
        KUBECONFIG_CREDENTIAL_ID = 'kubeconfig-info'
        // 您在 KubeSphere 创建的项目名称，不是 DevOps 项目名称
        PROJECT_NAME = 'test'
    }

    stages {
        stage('docker login') {
        steps{
            container ('go') {
                sh 'echo $DOCKERHUB_CREDENTIAL_PSW | docker login -u $DOCKERHUB_CREDENTIAL_USR --password-stdin'
            }
        }
    }

    stage('build & push') {
        steps {
            container ('go') {
                sh 'git config --global http.proxy "http://192.168.3.169:7890" && git config --global https.proxy "https://192.168.3.169:7890"'
                sh 'git clone https://gps.qianzhan.com/shaochengbao/devops-go-sample.git'
                sh 'cd devops-go-sample && docker build -t $REGISTRY/$DOCKERHUB_USERNAME/$APP_NAME .'
                sh 'docker push $REGISTRY/$DOCKERHUB_USERNAME/$APP_NAME'
                
                // 执行 docker logout命令清除缓存的docker登录信息：https://docs.docker.com/engine/reference/commandline/login/#credentials-store
                sh 'echo "执行 docker logout 命令前，docker配置信息为：" & cat /root/.docker/config.json'
                sh 'docker logout'
                sh 'echo "执行 docker logout 命令后，docker配置信息为：" & cat /root/.docker/config.json'
            }
        }
    }

    stage ('deploy app') {
        steps {
            container ('go') {
                withCredentials([
                    kubeconfigFile(
                      credentialsId: env.KUBECONFIG_CREDENTIAL_ID,
                      variable: 'KUBECONFIG')
                      ]) {
                        sh 'envsubst < devops-go-sample/manifest/deploy.yaml | kubectl apply -f -'
                      }
                  }
              }
          }
      }
}
