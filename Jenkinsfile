def label = 'jenkins-slave'
podTemplate(label: label,
        name: 'kubernetes',
        containers: [
                containerTemplate(name: 'maven', image: 'maven:3.3.9-jdk-8-alpine', ttyEnabled: true, command: 'cat')
        ],
        volumes: [
                hostPathVolume(hostPath: '/opt/maven', mountPath: '/usr/share/maven')
        ]) {
    node(label) {

        stage("初始化构建环境") {
            echo "正在初始化构建环境。。。"
            properties([[$class: 'JiraProjectProperty'],
                        parameters([
                                string(name: 'git_repo',
                                        defaultValue: 'https://github.com/swaince/jenkins-k8s-demo.git',
                                        description: 'git仓库',
                                        trim: true),
                                string(name: 'k8s_auth',
                                        defaultValue: '335c3f75-ac86-4ec0-973f-0e364a0c004a',
                                        description: 'k8s凭证',
                                        trim: true),
                                string(name: 'git_auth',
                                        defaultValue: '688ed8ce-b9fd-46e8-a0c1-3c518dbfb950',
                                        description: 'git凭证',
                                        trim: true),
                                gitParameter(name: 'git_branch',
                                        branch: '',
                                        branchFilter: '.*',
                                        defaultValue: 'master',
                                        description: '请选择远程分支，默认构建master',
                                        quickFilterEnabled: false,
                                        selectedValue: 'NONE',
                                        sortMode: 'NONE',
                                        tagFilter: '*',
                                        type: 'PT_BRANCH'),

                                booleanParam(name: 'skipTest',
                                        defaultValue: true,
                                        description: '是否跳过单元测试'),

                                extendedChoice(name: 'modules',
                                        defaultValue: 'client',
                                        description: '请选择需要构建部署的模块',
                                        descriptionPropertyValue: '注册中心,远程服务,客户端服务',
                                        multiSelectDelimiter: ',',
                                        quoteValue: false,
                                        saveJSONParameterToFile: false,
                                        type: 'PT_CHECKBOX',
                                        value: 'registry,service,client',
                                        visibleItemCount: 3)])])
        }

        stage("拉取代码") {

            echo "git_branch: ${git_branch}"
            echo "skipTest: ${skipTest}"
            echo "modules: ${modules}"

            echo "开始拉取源代码"
            checkout([$class                           : 'GitSCM',
                      branches                         : [[name: "master"]],
                      doGenerateSubmoduleConfigurations: false,
                      extensions                       : [[$class                           : 'CleanBeforeCheckout',
                                                           deleteUntrackedNestedRepositories: true]],
                      submoduleCfg                     : [],
                      userRemoteConfigs                : [[credentialsId: "${git_auth}",
                                                           url          : "${git_repo}"]]])
            echo("代码拉取完成")
        }

        stage("打包代码阶段") {
            container('maven') {
                stage("打包") {
                    sh 'mvn clean install'
                }
            }
            echo '打包完成'
        }

        //调用Kubernetes Continuous Deploy Plugin 插件
        stage('deploy') {
            sh "ls -al"
            sh "pwd"
            kubernetesDeploy(
                    kubeconfigId: "${k8s_auth}",
                    configs: 'deploy/*.yaml'
            )
        }
    }
}