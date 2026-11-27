pipeline {
    agent any

    environment {
        AWS_REGION   = 'ap-south-1'
        ECR_REPO     = 'demo-app'
        IMAGE_TAG    = "${env.BUILD_NUMBER}"
        HELM_VALUES  = 'helm/demo-app/values.yaml'
        GIT_REPO     = 'github.com/Bonigi/aws-eks-microservices-platform.git'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    stages {
        stage('CI') {
            // Skip builds triggered by Jenkins' own Helm tag commit
            when { not { changelog '.*\\[skip ci\\].*' } }
            stages {
                stage('Build & Test') {
                    steps {
                        sh 'mvn -B -f app/pom.xml clean verify'
                    }
                }

                stage('Docker Build') {
                    steps {
                        script {
                            env.ACCOUNT_ID = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
                            env.REGISTRY   = "${env.ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"
                            env.IMAGE      = "${env.REGISTRY}/${env.ECR_REPO}:${env.IMAGE_TAG}"
                        }
                        sh 'docker build -t "$IMAGE" .'
                    }
                }

                stage('Trivy Scan') {
                    steps {
                        // Fails the build on HIGH/CRITICAL vulnerabilities that have a fix
                        sh '''
                          trivy image --no-progress --ignore-unfixed \
                            --severity HIGH,CRITICAL --exit-code 1 \
                            --format table -o trivy-report.txt "$IMAGE"
                        '''
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
                        }
                    }
                }

                stage('Push to ECR') {
                    steps {
                        sh '''
                          aws ecr get-login-password --region "$AWS_REGION" \
                            | docker login --username AWS --password-stdin "$REGISTRY"
                          docker push "$IMAGE"
                        '''
                    }
                }

                stage('Update Helm Tag (GitOps)') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'github-token',
                                                          usernameVariable: 'GIT_USER',
                                                          passwordVariable: 'GIT_TOKEN')]) {
                            sh '''
                              sed -i "s|^\\(\\s*repository:\\).*|\\1 $REGISTRY/$ECR_REPO|" "$HELM_VALUES"
                              sed -i "s|^\\(\\s*tag:\\).*|\\1 \\"$IMAGE_TAG\\"|" "$HELM_VALUES"
                              git config user.email "jenkins@ci.local"
                              git config user.name  "Jenkins CI"
                              git add "$HELM_VALUES"
                              git commit -m "ci: deploy demo-app:$IMAGE_TAG [skip ci]"
                              git push "https://$GIT_USER:$GIT_TOKEN@$GIT_REPO" HEAD:main
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f || true'
        }
        success {
            echo "Deployed image tag ${IMAGE_TAG}; ArgoCD will sync it to EKS."
        }
    }
}
