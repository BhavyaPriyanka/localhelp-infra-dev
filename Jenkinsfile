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

        // stage('Plan'){
        //     steps{

        //     }
        // }

        // stage('Apply'){
        //     steps{
                   
        //     }
        // }

    }

    post{

            always{

                echo "Hello...BYE BYE!!"
            }

            success{

                echo "PIPELINE SUCCESSFULL.."
            }

            failure{

                echo "PIPELINE FAILURE.."
            }
    }

}