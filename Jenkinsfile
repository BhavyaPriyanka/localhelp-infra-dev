pipeline{

    agent {
                label 'AGENT-1'  
           }
    options{

        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        ansiColor('xterm')
    }

    stages{

        stage('Init'){
            steps{
             sh """

                            cd 01-VPC
                            terraform init -reconfigure
                       """
            }
        }

        stage('Test') {
            steps {
                echo 'Testing ANSI'

                sh '''
                printf "\\033[31mRED\\033[0m\n"
                printf "\\033[32mGREEN\\033[0m\n"
                printf "\\033[33mYELLOW\\033[0m\n"
                '''
            }
        }

        stage('Plan'){
            steps{
                sh """
                        cd 01-VPC
                        terraform plan
                """
            }
        }

        stage('Deploy'){

            input {

                message "CONTINUE? DID YOU CHECK ALL RESOURCES IN PLAN??"
                ok "YES"
                }
            
            steps{

                sh """
                        cd 01-VPC
                        terraform apply -auto-approve
                """
                   
            }
        }

    }

    post{

            always{

                echo "Hello...check status below !!"
                deleteDir()

            }

            success{

                echo "PIPELINE SUCCESSFULL.."
            }

            failure{

                echo "PIPELINE FAILURE.."
            }
    }
}

