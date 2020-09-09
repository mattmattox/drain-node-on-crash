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
              sh '''docker build -t drainnode/manager:"$BRANCH_NAME"-rc"$BUILD_NUMBER" .
docker push drainnode/manager:"$BRANCH_NAME"-rc"$BUILD_NUMBER"'''
            }

          }
        }

        stage('Build Docker image and push - Worker') {
          steps {
            dir(path: './worker') {
              sh '''docker build -t drainnode/worker:"$BRANCH_NAME"-rc"$BUILD_NUMBER" .
docker push drainnode/worker:"$BRANCH_NAME"-rc"$BUILD_NUMBER"'''
            }

          }
        }

        stage('Build Docker image and push - Leader') {
          steps {
            dir(path: './worker') {
              sh '''docker pull fredrikjanssonse/leader-elector:0.6
docker tag fredrikjanssonse/leader-elector:0.6 drainnode/leader:"$BRANCH_NAME"-rc"$BUILD_NUMBER"'''
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
mv drain-node-on-crash-*.tgz ~/helm-chart/'''
        }

      }
    }

    stage('Publishing') {
      steps {
        sh '''cd ~/helm-chart/
helm repo index ~/helm-chart/ --url https://mattmattox.github.io/helm-chart/
git add .
git commit -m "Jenkins Import"
git push'''
      }
    }

  }
}
