#!/usr/bin/env groovy

def build(nodeLabel) {
  node("${nodeLabel}") {
    deleteDir()
    unstash 'code'
    sh './bootstrap'
    sh './configure'
    sh 'make'
  }
}

pipeline {
    agent none
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 1, unit: 'HOURS')
    }
    triggers { cron('@daily') }
    stages {
        stage('prepare') {
            agent { label 'generic' }
            steps {
                deleteDir()
                checkout scm
                stash name: 'code'
            }
        }
        stage('build') {

            steps {
                parallel(
                    "build-umd3": { build("centos6-umd3") },
                    "build-umd4": { build("centos6-umd4") }
                )
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
            script{
                if('SUCCESS'.equals(currentBuild.result)) {
                    slackSend color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Back to normal (<${env.BUILD_URL}|Open>)"
                }
            }
        }
    }
}