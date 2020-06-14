def label = 'jenkins-slave'
podTemplate(label: label, name: 'kubernetes', containers: [
        containerTemplate(name: 'maven', image: 'maven:aliyun', ttyEnabled: true, command: 'cat')
]) {
    node (label){

        stage("初始化构建环境") {
            echo "正在初始化构建环境。。。"
            properties([[$class: 'JiraProjectProperty'],
                        parameters([
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
                      userRemoteConfigs                : [[credentialsId: "26830786-c9a1-4621-8cdc-871f51c1cd90",
                                                           url          : "https://github.com/swaince/jenkins-k8s-demo.git"]]])
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
            kubernetesDeploy(
                    kubeconfigId: '6c55a149-24d1-471b-8906-f87d45839e3d',
                    configs: 'deploy/*.yml'
            )
        }
    }
}