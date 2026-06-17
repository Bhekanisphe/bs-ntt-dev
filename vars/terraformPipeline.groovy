def call(Map config = [:]) {

    pipeline {
        agent any

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

            stage('Authenticate to AWS') {
                steps {
                    
                        withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: config.awsCredentialsId ?: 'ntt-aws-creds'
                        ]]) {
                            sh '''
                                echo "Authenticated to AWS"
                                aws sts get-caller-identity
                            '''
                        }
                    
                }
            }

            stage('Terraform Init') {
                steps {
                    
                        withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: config.awsCredentialsId ?: 'ntt-aws-creds'
                        ]]) {
                            sh '''
                                terraform --version
                                terraform init -input=false
                            '''
                        
                    }
                }
            }

            stage('Terraform Plan') {
                steps {
                    
                        withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: config.awsCredentialsId ?: 'ntt-aws-creds'
                        ]]) {
                            sh '''
                                terraform plan -out=tfplan
                            '''
                        }
                    
                }
            }

            stage('Terraform Apply') {
                when {
                    expression { return config.autoApply == true }
                }
                steps {
                    
                        withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: config.awsCredentialsId ?: 'ntt-aws-creds'
                        ]]) {
                            sh '''
                                terraform apply -auto-approve tfplan
                            '''
                        }
                    
                }
            }

            stage('Manual Approval Apply') {
                when {
                    expression { return config.autoApply != true }
                }
                steps {
                    input message: 'Approve Terraform Apply?', ok: 'Apply'

                    
                        withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: config.awsCredentialsId ?: 'ntt-aws-creds'
                        ]]) {
                            sh '''
                                terraform apply tfplan
                            '''
                        }
                    
                }
            }



        }

        post {
            always {
                echo 'Cleaning workspace...'
                cleanWs()
            }
            success {
                echo 'Terraform deployment completed successfully.'
            }
            failure {
                echo 'Terraform deployment failed.'
            }
        }
    }
}
