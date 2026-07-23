pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID         = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY     = credentials('AWS_SECRET_ACCESS_KEY')
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
                    // FIXED: Cleans any corrupted plugin files before starting init
                    sh 'rm -rf .terraform .terraform.lock.hcl'
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan -compact-warnings'
                    sh 'terraform apply -compact-warnings tfplan'
                }
            }
        }

        stage('Ansible Deployment') {
            steps {
                withCredentials([string(credentialsId: 'ANSIBLE_VAULT_PASSWORD', variable: 'VAULT_PASS')]) {
                    sshagent(['ec2-ssh-key']) {
                        dir('ansible') {
                            sh 'echo "$VAULT_PASS" > .vault_pass.txt'
                            sh 'ansible-playbook -i aws_ec2.yml deploy-playbook.yml --user ubuntu --vault-password-file .vault_pass.txt'
                            sh 'rm -f .vault_pass.txt'
                        }
                    }
                }
            }
        }

        stage('Monitoring Stack Deployment') {
            steps {
                withCredentials([string(credentialsId: 'ANSIBLE_VAULT_PASSWORD', variable: 'VAULT_PASS')]) {
                    sshagent(['ec2-ssh-key']) {
                        dir('ansible') {
                            sh 'echo "$VAULT_PASS" > .vault_pass.txt'
                            sh 'ansible-playbook -i aws_ec2.yml deploy-monitoring.yml --user ubuntu --vault-password-file .vault_pass.txt'
                            sh 'rm -f .vault_pass.txt'
                            echo 'Cooling down for AWS Target Group health stabilization routing...'
                            sh 'sleep 15' 
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
            echo 'Pipeline Failed. Standard cleanup logs initiated.'
        }
    }
}
