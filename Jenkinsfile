def infraChanges = false
def deleteChoice = ""
def applyChoice = ""

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

   
        stage('Plan'){
            steps{
                script{
                    int status = sh(
                        script: '''
                                    cd 01-VPC
                                    terraform plan -detailed-exitcode -out=tfplan
                                ''',
                        returnStatus: true
                    )

                    if (status==0){
                        echo "No infra changes detected"
                        infraChanges = false
                    }
                    else if (status==2){
                        echo "INFRA CHANGES DETECTED"
                        infraChanges = true
                    }
                    else{
                        error("Terraform Plan Failed")
                    }
                }


            }
        }


    stage('Deploy Confirmation'){

            when{
                expression { infraChanges }
            }

             applyChoice = input(
                message: "Terraform detected changes. Apply them?",
                parameters: [
                    choice(
                        name: 'ACTION',
                        choices: "CONTINUE\nAPPLY",
                        description: "Select an action"
                    )
                ]
            )

            steps{
              sh '''
                    cd 01-VPC
                    terraform apply -auto-approve tfplan
                    '''
            }

    }

    stage('Deploy') {
    when {
        expression { applyChoice == "APPLY" }
    }

    steps {
        sh '''
        cd 01-VPC
        terraform apply -auto-approve tfplan
        '''
    }
}

    stage('Destroy Confirmation'){

            when{ expression{!infraChanges} }
            

            steps{
               script{
              deleteChoice = input(
                    message: "INFRA ALREADY EXISTS. YOU WANT TO DESTROY IT?",
                    parameters: [
                            choice(
                                    name: 'ACTION',
                                    choices: "CONTINUE\nDESTROY",
                                    description: 'Select an action !!'
                            )

                    ]

                    
                )
                echo "deleteChoice = '${deleteChoice}'"
       
               }
            }
    }

    

    stage('Destroy'){

        when {
            expression { deleteChoice == "DESTROY"}
        }
        steps{
           sh '''
            cd 01-VPC
            terraform destroy -auto-approve
            '''
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
    }}
    



