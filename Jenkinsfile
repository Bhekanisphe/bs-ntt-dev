@Library('terraformPipeline@master', 'pythonLambda@master') _

terraformPipeline(
    region: 'af-south-1',
    awsCredentialsId: 'ntt-aws-creds',
    workingDir: '',
    autoApply: true
)

pythonLambda(
    sourceDir: 'lambda_functions',
    requirements: 'requirements.txt',
    requirementsDev: 'requirements-dev.txt',
    coverageThreshold: 80
)