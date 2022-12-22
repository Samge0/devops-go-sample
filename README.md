## kubusphere 的 devops 测试


步骤：
    - 在 kubesphere 的devops流水线中配置凭据信息：docker凭据、git凭据（如果时私有仓库则需要配置）、kubesphere配置凭据
    - 在 kubesphere 中创建流水线，指定git仓库为本仓库，设置触发流水线的分支&Dockerfile文件路径，将webhook的链接地址在git中配置；
    - 提交更新到指定分支，触发流水线编译：登录docker 》 拉取git代码 》 docker镜像编译并发布 》 k8s部署 》 清理临时资源

## 其他
    - kubesphere部署在本地的话，则wenhook的url是本地链接，如果要配置到远程github或其他仓库测试，则需要用frp或其他内网穿透脚本处理一下；
    - 如果有内网的gitlab仓库跟docker仓库，则用内网仓库进行测试更好些