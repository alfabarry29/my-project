pipeline {
    agent { label 'docker-deploy' }

    options {
        disableConcurrentBuilds()
        skipDefaultCheckout()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-project:$GIT_COMMIT .'
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    set -eu
                    existing=$(docker container ls -aq --filter 'name=^/my-project$')
                    if [ -n "$existing" ]; then
                        docker container stop my-project
                        docker container rm my-project
                    fi
                    docker run -d --name my-project -p 5000:5000 "my-project:$GIT_COMMIT"
                '''
            }
        }
    }
}
