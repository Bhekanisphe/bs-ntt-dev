def call(Map config = [:]) {
    def pythonVersion     = config.pythonVersion     ?: '3.14.4'
    def sourceDir         = config.sourceDir         ?: 'lambda_functions'
    def testsDir          = config.testsDir          ?: 'tests'
    def requirements      = config.requirements      ?: 'requirements.txt'
    def requirementsDev   = config.requirementsDev   ?: 'requirements-dev.txt'
    def coverageThreshold = config.coverageThreshold ?: 80

    stage('Setup Python') {
        sh """
            python${pythonVersion} -m venv .venv
            . .venv/bin/activate
            pip install --upgrade pip
            if [ -f ${requirements} ]; then pip install -r ${requirements}; fi
            if [ -f ${requirementsDev} ]; then pip install -r ${requirementsDev}; fi
            pip install --quiet black flake8 mypy pytest pytest-cov
        """
    }

    stage('Format Check') {
        sh """
            . .venv/bin/activate
            black --check --diff ${sourceDir}
        """
    }

    stage('Lint') {
        sh """
            . .venv/bin/activate
            flake8 ${sourceDir} --max-line-length=120
        """
    }

    stage('Type Check') {
        sh """
            . .venv/bin/activate
            mypy ${sourceDir}
        """
    }

}
