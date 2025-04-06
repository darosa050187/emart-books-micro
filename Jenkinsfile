def notifySlack(String buildStatus) {
    def colorCode = buildStatus == 'SUCCESS' ? '#36a64f' : '#ff0000'
    def summary = "*Job:* ${env.JOB_NAME} #${env.BUILD_NUMBER}\n" +
                 "*Status:* ${buildStatus}\n" +
                 "*Duration:* ${currentBuild.durationString}\n" +
                 "*Details:* ${env.BUILD_URL}"

    slackSend(
        channel: env.SLACK_CHANNEL,
        color: colorCode,
        message: summary,
        tokenCredentialId: env.SLACK_CREDENTIALS_ID
    )
}
pipeline{
    agent any 
    environment{
        REQUIRED_TOOLS = "docker, aws, java"
        BRANCH_NAME = "feature-login-start"
        PROJECT_NAME = "emart-app-landing"
        PROJECT_FOLDER = "javaapi"
        GIT_REPO_URL = "https://github.com/darosa050187/emart-books-micro.git"
    }
    stages{
        stage("Validate Jenkins Environment Tools"){
            steps{
                script{
                    def tools = REQUIRED_TOOLS.split(',').collect { it.trim() }
                    echo "Checking for required tools: ${tools.join(', ')}"
                    tools.each { tool ->
                        echo "Checking for ${tool}..."
                        def exitCode = sh(script: "which ${tool}", returnStatus: true)
                        if (exitCode != 0) {
                            error "Required tool '${tool}' is not installed"
                        }
                    }
                }
            }
            post{
                always{
                    echo "###########################################"
                    echo "#### VALIDATE JENKINS ENVIRONMENT TOOLS ###"
                    echo "###########################################"
                }
                success{
                    echo "All required tools are available"
                }
                failure{
                    error "Required tool '${tool}' is not installed"
                }
            }
        }
        stage('List files in repo on Unix Slave') {
            steps {
                echo "Workspace location: ${env.WORKSPACE}"    
                sh 'ls -l'
            }
        }
        stage("Checkout project from github") {
            steps {
                dir("${env.WORKSPACE}/tmp/") {
                    sh "git clone --branch ${BRANCH_NAME} ${GIT_REPO_URL}"
                }
            }
        }
        stage("Code Test Processes") {
            parallel {
                // stage("Unit Test") {
                //     steps {
                //         dir("${env.WORKSPACE}/tmp/${env.PROJECT_FOLDER}") {
                //             sh 'mvn test'
                //         }
                //     }
                // }
                // stage("Integration Test") {
                //     steps {
                //         dir("${env.WORKSPACE}/tmp/${env.PROJECT_FOLDER}") {
                //             sh 'mvn verify -e'
                //         }
                //     }
                // }
                // stage("Code Analysis With Check Style") {
                //     steps {
                //         dir("${env.WORKSPACE}/tmp/${env.PROJECT_FOLDER}") {
                //             sh 'mvn checkstyle:checkstyle'
                //         }
                //     }
                // }
                stage("Build and compile") {
                    steps {
                        dir("${env.WORKSPACE}/tmp/${env.PROJECT_FOLDER}") {
                            sh 'mvn install -DskipTests'
                        }
                    }
                }
                stage("Check Code With Sonar Qube") {
                    environment {
                        scannerHome = tool 'sonar6.2'
                    }
                    steps {
                        dir("${env.WORKSPACE}/tmp/${env.PROJECT_FOLDER}") {
                            withSonarQubeEnv('Jenkins2Sonar') {
                            sh '''${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=emart_books_api \
                            -Dsonar.projectName=emart_books_api \
                            -Dsonar.projectVersion=1.0 \
                            -Dsonar.sources=javaapi/src/ \
                            -Dsonar.java.binaries=.  '''

                            }
                        }
                    }
                }
                stage("Quality Gate") {
                    steps {
                        timeout(time: 1, unit: 'HOURS') {
                            waitForQualityGate abortPipeline: true
                        }
                    }
                }
            }
        }
        // stage('Build docker image') {
        //     steps {

        //     }
        // }
        stage('Clean up process') {
            steps {
                dir("${env.WORKSPACE}/tmp/${env.PROJECT_NAME}") {
                            sh "rm -rf ${env.PROJECT_NAME}"
                        }
            }
        }
    }
    post{
        always{
            script {
                if (currentBuild.result == 'SUCCESS') {
                    notifySlack('SUCCESS')
                }
                else if (currentBuild.result == 'FAILURE') {
                    notifySlack('FAILURE')
                }
                else if (currentBuild.result == 'UNSTABLE') {
                    notifySlack('UNSTABLE')
                }
            }
        }
        success{
            echo "========pipeline executed successfully ========"
        }
        failure{
            echo "========pipeline execution failed========"
        }
    }
}