#!/bin/bash
 
JENKINS_URL=$1
NODE_NAME=$2
NODE_HOME='/home/ubuntu'
EXECUTORS=1
SSH_PORT=22
CRED_ID='ubuntu-slave1'
LABELS=build
USERID=${USER}
 
cat <<EOF | java -jar jenkins-cli.jar -s $1 create-node project-slave
<slave>
  <name>PROJECT_SLAVE1</name>
  <description></description>
  <remoteFS>${NODE_HOME}</remoteFS>
  <numExecutors>${EXECUTORS}</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.5">
    <host>${NODE_NAME}</host>
    <port>${SSH_PORT}</port>
    <credentialsId>${CRED_ID}</credentialsId>
  </launcher>
  <label>${LABELS}</label>
  <nodeProperties/>
  <userId>${USERID}</userId>
</slave>
EOF