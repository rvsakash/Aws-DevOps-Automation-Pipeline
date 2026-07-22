pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'us-east-1'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    options {
        disableConcurrentBuilds()
    }

    triggers {
        pollSCM('* * * * *') 
    }

    stages {
        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
                dir('ansible') {
                    sh 'echo "[webserver]" > hosts'
                    sh 'echo "[tags_Role_webserver]" >> hosts'
                    // Bulletproof Fix: Seedhe AWS API se live IPs nikal kar hosts file mein dalo
                    sh 'aws ec2 describe-instances --filters "Name=tag:Role,Values=webserver" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].PublicIpAddress" --output json | jq -r ".[][]" >> hosts'
                    sh 'cat hosts'
                }
            }
        }

        stage('Ansible Deployment') {
            steps {
                withCredentials([string(credentialsId: 'ANSIBLE_VAULT_PASSWORD', variable: 'VAULT_PASS')]) {
                    sshagent(['ec2-ssh-key']) {
                        dir('ansible') {
                            sh 'echo "$VAULT_PASS" > .vault_pass.txt'
                            sh 'ansible-playbook -i hosts deploy-playbook.yml --user ubuntu --vault-password-file .vault_pass.txt'
                            sh 'rm -f .vault_pass.txt'
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline Completed Successfully! App Is Live!'
        }
        failure {
            dir('ansible') { 
                sh 'rm -f .vault_pass.txt' 
            }
            echo 'Pipeline Failed. Please check Jenkins logs.'
        }
    }
}

// AWS CLI Live IP Discovery Patch
