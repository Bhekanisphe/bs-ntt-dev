def call(Map config = [:]) {
    pipeline {
    agent any



    environment {
        PYTHON_VERSION      = '3.12'
        SOURCE_DIR          = 'lambda_functions'
        REQUIREMENTS        = 'requirements.txt'   // optional, only installed if present
        REQUIREMENTS_DEV    = 'requirements-dev.txt'   // optional, only installed if present
        COVERAGE_THRESHOLD  = '80'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Python') {
            steps {
                sh """
                    python${PYTHON_VERSION} -m venv .venv
                    . .venv/bin/activate
                    pip install --upgrade pip
                    if [ -f ${REQUIREMENTS} ]; then pip install -r ${REQUIREMENTS}; fi
                    if [ -f ${REQUIREMENTS_DEV} ]; then pip install -r ${REQUIREMENTS_DEV}; fi
                    pip install --quiet black flake8 mypy pytest pytest-cov
                """
            }
        }

        stage('Format Check') {
            steps {
                sh """
                    . .venv/bin/activate
                    black --check --diff ${SOURCE_DIR}
                """
            }
        }

        stage('Lint') {
            steps {
                sh """
                    . .venv/bin/activate
                    flake8 ${SOURCE_DIR} --max-line-length=120
                """
            }
        }

        stage('Type Check') {
            steps {
                sh """
                    . .venv/bin/activate
                    mypy ${SOURCE_DIR}
                """
            }
        }

    }

    post {
        success {
            echo "✅ Verification passed — safe to hand off to the Terraform pipeline."
        }
        failure {
            echo "❌ Verification failed — see stage logs above. Deployment should not proceed."
        }
        always {
            junit allowEmptyResults: true, testResults: 'reports/junit.xml'
            cleanWs()
        }
    }
}
}