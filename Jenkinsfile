#!/usr/bin/env groovy

pipeline {

    agent {
        kubernetes {
            label "build-storm-gridftp-dsi-${env.BUILD_NUMBER}"
            cloud 'Kube mwdevel'
            defaultContainer 'jnlp'
            yamlFile 'jenkins/pod.yaml'
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
                container('kube-storm-build') {
		    script {
                        sh './bootstrap'
                        sh './configure'
                        sh 'make'
                    }
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
            script{
                if('SUCCESS'.equals(currentBuild.result)) {
                    slackSend color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Back to normal (<${env.BUILD_URL}|Open>)"
                }
            }
        }
    }
}
