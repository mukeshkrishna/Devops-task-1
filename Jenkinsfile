pipeline {
    agent any
    tools {
        nodejs 'node'
    }
    environment{
        env.IMAGE_NAME = "myapp-1.0.0"
    }
    stages {
        stage('Provision EKS Cluster') {
            steps {
                script {
                    dir('terraform') {
                        echo "Creating ECR repository and EKS cluster"
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        env.DOCKER_REPO_URL = sh(
                            script: "terraform output repo_url",
                            returnStdout: true
                        ).trim()
                        env.K8S_CLUSTER_URL = sh(
                            script: "terraform output cluster_url",
                            returnStdout: true
                        ).trim()
                        env.REPO_USER = sh(
                            script: "terraform output ecr_user_name",
                            returnStdout: true
                        ).trim()
                        env.REPO_PWD = sh(
                            script: "terraform output ecr_user_password",
                            returnStdout: true
                        ).trim()
                    }
                    env.KUBECONFIG="terraform/kubeconfig.yaml"
                    sh "kubectl get node"
                }
            }
        }
        stage("Static Code Analysis"){
            environment{
                SONARQUBE_URL=http://<DOCKERHOSTIP>:9000
                SONARQUBE_PROJECTKEY=helloworld
                SONARQUBE_TOKEN=<SONARQUBE_TOKEN>
            }
            steps{
                script{
                    sh 'npm install --save-dev sonarqube-scanner'
                    sh 'npm run sonar'
                }
            }
        }
        stage('build nodejs image') {
            steps {
                script {
                    echo "building the docker image..."
                    sh "docker build -t ${DOCKER_REPO_URL}:${IMAGE_NAME} ."
                    sh "echo ${REPO_PWD} | docker login -u ${REPO_USER} --password-stdin ${DOCKER_REPO_URL}"
                    sh "docker push ${DOCKER_REPO_URL}:${IMAGE_NAME}"
                }
            }
        }
        stage('deploy') {
            environment {
                APP_NAME = 'myapp'
            }
            steps {
                script {
                    echo 'Deploying onto EKS cluster...'
                    sh 'envsubst < kubernetes/certificate_issuer.yaml | kubectl apply -f -'
                    sh 'envsubst < kubernetes/deployment.yaml | kubectl apply -f -'
                    sh 'envsubst < kubernetes/service.yaml | kubectl apply -f -'
                }
            }
        }


    }
}
