@Library(['terraformPipeline@master', 'pythonLambda@master']) _

pipeline {
    agent any

    options {
        timestamps()
        ansiColor('xterm')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    environment {
        AWS_DEFAULT_REGION = 'af-south-1'
        TF_IN_AUTOMATION   = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Python Lambda') {
            steps {
                script {
                    pythonLambda(
                        sourceDir:         'lambda_functions',
                        requirements:      'requirements.txt',
                        requirementsDev:   'requirements-dev.txt',
                        coverageThreshold: 80
                    )
                }
            }
        }

        stage('Terraform Deploy') {
            steps {
                script {
                    terraformPipeline(
                        region:           'af-south-1',
                        awsCredentialsId: 'ntt-aws-creds',
                        workingDir:       '',
                        autoApply:        true
                    )
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed — see stage logs above.'
        }
        always {
            cleanWs()
        }
    }
}
