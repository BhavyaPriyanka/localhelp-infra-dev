pipeline{

    agent {
                label 'AGENT-1'  
           }
    options{

        timeout(time: 30, UNIT: minutes)
        disableConcurrentBuilds()
    }

    stages{

        stage('Init'){
            steps{
            
            }
        }

        stage('Plan'){
            steps{

            }
        }

        stage('Apply'){
            steps{
                    sh """

                            ls -ltr 
                       """
            }
        }

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