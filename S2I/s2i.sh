yum install centos-release-scl-rh
yum --enablerepo=centos-sclo-rh-testing install source-to-image

docker pull registry.centos.org/dotnet/dotnet-21-centos7:latest


NuGet.Config

<configuration>
    <packageSources>
	<add key="repo" value="http://192.168.168.34/repository/nuget-hosted/" />
    </packageSources>
</configuration>



s2i build http://gogs-persistent.apps.snt.local/cicd/sadtahlil.git registry.centos.org/dotnet/dotnet-21-centos7:latest afshin  -e DOTNET_STARTUP_PROJECT=SadTahli.WebApi/src/SadTahli.WebApi.csproj -e DOTNET_PUBLISH=/opt/app-root/app/  -e DOTNET_ASSEMBLY_NAME=Soshyant.Repo.SadTahli.WebApi -p always



oc new-project sadtahlil
oc adm policy add-role-to-user admin admin -n sadtahlil
oc new-app --name=sadtahlil  'registry.centos.org/dotnet/dotnet-21-centos7:latest~http://gogs-persistent.apps.snt.local/cicd/sadtahlil.git' --build-env  DOTNET_STARTUP_PROJECT=SadTahli.WebApi/src/SadTahli.WebApi.csproj  --build-env  DOTNET_ASSEMBLY_NAME=Soshyant.Repo.SadTahli.WebApi --build-env  httpport=8080 --build-env  httpsport=8090 --build-env  ASPNETCORE_URLS=http://*:8080,https://*:8090
oc expose svc sadtahlil


oc new-project marketwatch1
oc adm policy add-role-to-user admin admin -n marketwatch1
oc new-app --name=marketwatch  'registry.centos.org/dotnet/dotnet-21-centos7:latest~http://gogs-persistent.apps.snt.local/cicd/marketwatch.git' --build-env  DOTNET_STARTUP_PROJECT=MarketWatch.WebApi/src/MarketWatch.WebApi.csproj  --build-env  DOTNET_ASSEMBLY_NAME=Soshyant.Repo.MarketWatch.WebApi --build-env  httpport=8080 --build-env  httpsport=8090 --build-env  ASPNETCORE_URLS=http://*:8080,https://*:8090
oc expose svc marketwatch






oc new-project emc
oc adm policy add-role-to-user admin admin -n emc
oc new-app --name=emc  'registry.centos.org/dotnet/dotnet-21-centos7:latest~http://gogs-persistent.apps.snt.local/cicd/EMC.git' --build-env DOTNET_STARTUP_PROJECT=EmaliServer/EmailServer.WebApi/EmailServer.WebApi.csproj --build-env  DOTNET_ASSEMBLY_NAME=Soshyant.Repo.EmailServer.WebApi  --build-env  httpport=8080 --build-env  httpsport=8090 --build-env  ASPNETCORE_URLS=http://*:8080,https://*:8090
oc expose svc emc


oc export is,bc,dc,svc --as-template=sadtahlil  > template.json

#Create template from live project
oc export BuildConfig,DeploymentConfig,ReplicationController,Service,Route,ImageStream -o json  --as-template='sadtahlil' > sadtahlil-template.json




push template to gogs

http://gogs-persistent.apps.snt.local/cicd/templates/raw/master/sadtahlil-template.json

--------------------------------------------


vim sadtahlil-pipeline.yaml

kind: "BuildConfig"
apiVersion: "v1"
metadata:
  name: "sadtahlil-pipeline"
spec:
  strategy:
    jenkinsPipelineStrategy:
      jenkinsfile: |-
// path of the template to use
def templatePath = 'http://gogs-persistent.apps.snt.local/cicd/templates/raw/master/sadtahlil-template.json'
// name of the template that will be created
def templateName = 'sadtahlil'
// NOTE, the "pipeline" directive/closure from the declarative pipeline syntax needs to include, or be nested outside,
// and "openshift" directive/closure from the OpenShift Client Plugin for Jenkins.  Otherwise, the declarative pipeline engine
// will not be fully engaged.
pipeline {
    agent any
    options {
        // set a timeout of 20 minutes for this pipeline
        timeout(time: 20, unit: 'MINUTES')
    }
    stages {
        stage('preamble') {
            steps {
                
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            echo "Using project: ${openshift.project()}"
                            deleteDir()
                        }
                    }
                }
            }
        }
        stage('checkout'){
            steps {
                checkout([$class: 'TeamFoundationServerScm', credentialsConfigurer: [$class: 'AutomaticCredentialsConfigurer'], projectPath: '$/ThirdParty', serverUrl: 'http://192.168.168.10:1397/tfs/SoshyantRepoTeam', useOverwrite: true, useUpdate: true, workspaceName: '${JOB_NAME}-${NODE_NAME}-F'])
                sh '''
		        cat << EOF > ./100Tahlil/NuGet.Config
<configuration>
    <packageSources>
	<add key="repo" value="http://192.168.168.34/repository/nuget-group/" />
    </packageSources>
</configuration>
EOF
		        '''
		        
		        sh "git init"
		        sh "git add ."
                sh 'git commit -m "build $BUILD_NUMBER"'
                sh "git  push  http://cicd:S0shyant123@gogs-persistent.apps.snt.local/cicd/sadtahlil.git master -f ; exit 0;"
            }
        }
        stage('cleanup') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            // delete everything with this template label
                            openshift.selector("all", [ template : templateName ]).delete()
                            // delete any secrets with this template label
                            if (openshift.selector("secrets", templateName).exists()) {
                                openshift.selector("secrets", templateName).delete()
                            }
                            if (openshift.selector("imagestream").exists()) {
                                openshift.selector("imagestream").delete()
                            }
                            if (openshift.selector("svc","sadtahlil").exists()) {
                                openshift.selector("svc","sadtahlil").delete()
                            }
                            if (openshift.selector("bc","sadtahlil").exists()) {
                                openshift.selector("bc","sadtahlil").delete()
                            }
                            if (openshift.selector("dc","sadtahlil").exists()) {
                                openshift.selector("dc","sadtahlil").delete()
                            }
                            if (openshift.selector("routes","sadtahlil").exists()) {
                                openshift.selector("routes","sadtahlil").delete()
                            }
                           
                        }
                    }
                } // script
            } // steps
        } // stage
        stage('create') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            // create a new application from the templatePath
                            openshift.newApp(templatePath)
                        }
                    }
                } // script
            } // steps
        } // stage
        stage('build') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            def builds = openshift.selector("bc", templateName).related('builds')
                            builds.untilEach(1) {
                                return (it.object().status.phase == "Complete")
                            }
                        }
                    }
                } // script
            } // steps
        } // stage
        stage('deploy') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            def rm = openshift.selector("dc", templateName).rollout()
                            openshift.selector("dc", templateName).related('pods').untilEach(1) {
                                return (it.object().status.phase == "Running")
                            }
                        }
                    }
                } // script
            } // steps
        } // stage
        stage('tag') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            // if everything else succeeded, tag the ${templateName}:latest image as ${templateName}-staging:latest
                            // a pipeline build config for the staging environment can watch for the ${templateName}-staging:latest
                            // image to change and then deploy it to the staging environment
                            openshift.tag("${templateName}:latest", "${templateName}-staging:latest")
                        }
                    }
                } // script
            } // steps
        } // stage
    } // stages
} // pipeline


oc new-project cicd
oc adm policy add-role-to-user admin admin -n cicd

oc new-app -e --name=cicd \
INSTALL_PLUGINS=tfs \
OVERRIDE_PV_PLUGINS_WITH_IMAGE_PLUGINS=true \
jenkins-ephemeral

oc adm policy add-scc-to-user anyuid -z default

#Wait for jenkins up and running
oc create -f sadtahlil-pipeline.yaml
oc start-build sadtahlil-pipeline


mkdir marketwatch
cd marketwatch/
vim marketwatch-pipeline.yaml
oc create -f marketwatch-pipeline.yaml
---------------------------------------------------------------------------------------------------------------------




oc new-app -e \
INSTALL_PLUGINS=tfs \
OVERRIDE_PV_PLUGINS_WITH_IMAGE_PLUGINS=true \
jenkins-ephemeral


oc create -f 100Tahlil-pipeline.yaml