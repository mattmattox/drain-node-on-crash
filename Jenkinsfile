pipeline {
  agent any
  stages {
    stage('Build Docker images') {
      steps {
        dir(path: './manager/') {
          sh '''docker built -t docker.pkg.github.com/mattmattox/drain-node-on-crash/manager:$BRANCH_NAME . && \\
docker push docker.pkg.github.com/mattmattox/drain-node-on-crash/manager:$BRANCH_NAME'''
        }

        dir(path: './worker/') {
          sh '''docker built -t docker.pkg.github.com/mattmattox/drain-node-on-crash/worker:$BRANCH_NAME . && \\
docker push docker.pkg.github.com/mattmattox/drain-node-on-crash/worker:$BRANCH_NAME'''
        }

      }
    }

  }
}