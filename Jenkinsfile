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
              sh '''docker build -t docker.pkg.github.com/mattmattox/drain-node-on-crash/manager:"$BRANCH_NAME"-rc"$BUILD_NUMBER" .
docker push docker.pkg.github.com/mattmattox/drain-node-on-crash/manager:"$BRANCH_NAME"-rc"$BUILD_NUMBER"'''
            }

          }
        }

        stage('Build Docker image and push - Worker') {
          steps {
            dir(path: './worker') {
              sh '''docker build -t docker.pkg.github.com/mattmattox/drain-node-on-crash/worker:"$BRANCH_NAME"-rc"$BUILD_NUMBER" .
docker push docker.pkg.github.com/mattmattox/drain-node-on-crash/worker:"$BRANCH_NAME"-rc"$BUILD_NUMBER"'''
            }

          }
        }

        stage('Build Docker image and push - Leader') {
          steps {
            dir(path: './worker') {
              sh '''docker pull k8s.gcr.io/leader-elector:0.5
docker tag k8s.gcr.io/leader-elector:0.5 docker.pkg.github.com/mattmattox/drain-node-on-crash/leader:"$BRANCH_NAME"-rc"$BUILD_NUMBER"'''
            }

          }
        }

      }
    }

    stage('Packaging') {
      steps {
        dir(path: './chart') {
          sh '''echo "Removing old packages..."
rm -f drain-node-on-crash-*.tgz

echo "Packing chart using helm..."
helm package ./drain-node-on-crash/ \\
--app-version="$BRANCH_NAME"-rc"$BUILD_NUMBER" \\
--version="$BRANCH_NAME"-rc"$BUILD_NUMBER"

echo "Moving package..."
mv drain-node-on-crash-*.tgz /opt/charts/'''
        }

      }
    }

    stage('Publishing') {
      steps {
        sh 'helm repo index /opt/charts/ --url https://charts.suport.tools'
      }
    }

  }
}