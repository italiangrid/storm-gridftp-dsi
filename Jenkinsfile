#!/usr/bin/env groovy

@Library('sd')_
def kubeLabel = getKubeLabel()

pipeline {

  agent {
    kubernetes {
      label "${kubeLabel}"
      cloud 'Kube mwdevel'
      defaultContainer 'runner'
      inheritFrom 'ci-template'
      containerTemplate {
        name 'runner'
        image "italiangrid/storm-build:centos6"
        ttyEnabled true
        command 'cat'
      }
    }
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    timeout(time: 1, unit: 'HOURS')
  }

  triggers { cron('@daily') }

  stages {
    stage('Run') {
      steps {
        script {
          sh './bootstrap'
          sh './configure'
          sh 'make'
        }
      }
    }
    stage('result') {
      steps {
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
      script {
        if ('SUCCESS'.equals(currentBuild.result)) {
          slackSend color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Back to normal (<${env.BUILD_URL}|Open>)"
        }
      }
    }
  }
}
