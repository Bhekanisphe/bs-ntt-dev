def call(Map config = [:]) {
    def credentialsId = config.awsCredentialsId ?: 'ntt-aws-creds'
    def workingDir    = config.workingDir ?: ''
    def autoApply     = config.autoApply == true

    def runStages = {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: credentialsId
        ]]) {
            stage('Authenticate to AWS') {
                sh 'aws sts get-caller-identity'
            }

            stage('Terraform Init') {
                sh """
                    terraform --version
                    terraform init -input=false
                """
            }

            stage('Terraform Validate') {
                sh 'terraform validate'
            }

            stage('Terraform Plan') {
                sh 'terraform plan -out=tfplan'
            }

            if (autoApply) {
                stage('Terraform Apply') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            } else {
                stage('Manual Approval Apply') {
                    input message: 'Approve Terraform Apply?', ok: 'Apply'
                    sh 'terraform apply tfplan'
                }
            }
        }
    }

    if (workingDir?.trim()) {
        dir(workingDir) { runStages() }
    } else {
        runStages()
    }
}
