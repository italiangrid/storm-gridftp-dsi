pipeline {
  
    agent { label 'centos6' }
    
      options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 1, unit: 'HOURS')
      }
    
      triggers { cron('@daily') }
    
      stages {
        stage('prepare'){
          steps {
            checkout scm
          }
        }
    
        stage('bootstrap') {
          steps {
            sh './bootstrap'
          }
        }

        stage('configure') {
          steps {
            sh './configure'
          }
        }

        stage('make') {
          steps {
            sh 'make'
            script {
              currentBuild.result = 'SUCCESS'
            }
          }
        }
      }

      post {
        failure {
          slackSend color: 'danger', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Failure (<${env.BUILD_URL}|Open>)"
        }
        unstable {
          slackSend color: 'warning', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Unstable (<${env.BUILD_URL}|Open>)"
        }
        changed {
          script{
            if('SUCCESS'.equals(currentBuild.result)) {
              slackSend color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Back to normal (<${env.BUILD_URL}|Open>)"
            }
          }
        }
      }
  
  }