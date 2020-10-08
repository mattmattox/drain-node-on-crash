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
              sh '''if [[ ${params.CutRelease} == "true" ]]
then
  imagetag="$BRANCH_NAME"
else
  if [[ "$BRANCH_NAME" == "master" ]]
  then
    imagetag="master-b"$BUILD_NUMBER
  else
    imagetag="$BRANCH_NAME"-rc"$BUILD_NUMBER"
  fi
fi
docker build -t docker.pkg.github.com/mattmattox/drain-node-on-crash/manager:"$imagetag" .
docker push docker.pkg.github.com/mattmattox/drain-node-on-crash/manager:"$imagetag"
            }

          }
        }

        stage('Build Docker image and push - Worker') {
          steps {
            dir(path: './worker') {
              sh '''if [[ ${params.CutRelease} == "true" ]]
then
  imagetag="$BRANCH_NAME"
else
  if [[ "$BRANCH_NAME" == "master" ]]
  then
    imagetag="master-b"$BUILD_NUMBER
  else
    imagetag="$BRANCH_NAME"-rc"$BUILD_NUMBER"
  fi
fi
docker build -t docker.pkg.github.com/mattmattox/drain-node-on-crash/worker:"$imagetag" .
docker push docker.pkg.github.com/mattmattox/drain-node-on-crash/worker:"$imagetag"
            }

          }
        }

        stage('Build Docker image and push - Leader') {
          steps {
            dir(path: './worker') {
              sh '''if [[ "${params.CutRelease}" == "true" ]]
then
  imagetag="$BRANCH_NAME"
else
  if [[ "$BRANCH_NAME" == "master" ]]
  then
    imagetag="master-b"$BUILD_NUMBER
  else
    imagetag="$BRANCH_NAME"-rc"$BUILD_NUMBER"
  fi
fi
docker pull fredrikjanssonse/leader-elector:0.6
docker tag fredrikjanssonse/leader-elector:0.6 docker.pkg.github.com/mattmattox/drain-node-on-crash/leader:"$imagetag" .
docker push docker.pkg.github.com/mattmattox/drain-node-on-crash/leader:"$imagetag"'''
'''
            }

          }
        }

      }
    }

    stage('Packaging') {
      steps {
        dir(path: './chart') {
          sh '''if [[ "${params.CutRelease}" == "true" ]]
then
  imagetag="$BRANCH_NAME"
else
  if [[ "$BRANCH_NAME" == "master" ]]
  then
    imagetag="master-b"$BUILD_NUMBER
  else
    imagetag="$BRANCH_NAME"-rc"$BUILD_NUMBER"
  fi
fi

echo "Removing old packages..."
rm -f drain-node-on-crash-*.tgz

echo "Packing chart using helm..."
helm package ./drain-node-on-crash/ \\
--app-version="$imagetag" \\
--version="$imagetag"

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
  parameters {
    booleanParam(name: 'CutRelease', defaultValue: false, description: 'Create Public Release')
  }
}
