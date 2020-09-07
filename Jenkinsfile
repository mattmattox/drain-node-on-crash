pipeline {
  agent any
  stages {
    stage('Login to Docker repo') {
      steps {
        sh '''cat ~/.GH_TOKEN | docker login docker.pkg.github.com -u mattmattox --password-stdin
'''
      }
    }

    stage('Docker') {
      parallel {
        stage('Build Docker image and push - Manager') {
          steps {
            dir(path: './manager') {
              sh '''docker build -t docker.pkg.github.com/mattmattox/drain-node-on-crash/manager:$GIT_COMMIT .
docker push docker.pkg.github.com/mattmattox/drain-node-on-crash/manager:$GIT_COMMIT'''
            }

          }
        }

        stage('Build Docker image and push - Worker') {
          steps {
            dir(path: './worker') {
              sh '''docker build -t docker.pkg.github.com/mattmattox/drain-node-on-crash/worker:$GIT_COMMIT .
docker push docker.pkg.github.com/mattmattox/drain-node-on-crash/worker:$GIT_COMMIT'''
            }

          }
        }

      }
    }

  }
}
