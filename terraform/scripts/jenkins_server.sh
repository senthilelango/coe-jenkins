#!/bin/bash

set -x
sudo su
function wait_for_jenkins()
{
  while (( 1 )); do
      echo "waiting for Jenkins to launch on port [8080] ..."
      
      nc -zv 127.0.0.1 8080
      if (( $? == 0 )); then
          break
      fi

      sleep 10
  done

  echo "Jenkins launched"
}

function updating_jenkins_master_password ()
{
  cat > /tmp/jenkinsHash.py <<EOF
import bcrypt
import sys

if not sys.argv[1]:
  sys.exit(10)

plaintext_pwd=sys.argv[1]
encrypted_pwd=bcrypt.hashpw(sys.argv[1], bcrypt.gensalt(rounds=10, prefix=b"2a"))
isCorrect=bcrypt.checkpw(plaintext_pwd, encrypted_pwd)

if not isCorrect:
  sys.exit(20);

print "{}".format(encrypted_pwd)
EOF

  chmod +x /tmp/jenkinsHash.py
  
  # Wait till /var/lib/jenkins/users/admin* folder gets created
  sleep 10

  cd /var/lib/jenkins/users/admin*
  pwd
  while (( 1 )); do
      echo "Waiting for Jenkins to generate admin user's config file ..."

      if [[ -f "./config.xml" ]]; then
          break
      fi

      sleep 10
  done

  echo "Admin config file created"

  admin_password=$(python /tmp/jenkinsHash.py ${jenkins_admin_password} 2>&1)
  
  # Please do not remove alter quote as it keeps the hash syntax intact or else while substitution, $<character> will be replaced by null
  xmlstarlet -q ed --inplace -u "/user/properties/hudson.security.HudsonPrivateSecurityRealm_-Details/passwordHash" -v '#jbcrypt:'"$admin_password" config.xml

  # Restart
  systemctl restart jenkins
  sleep 10
}

function install_packages ()
{

  wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
  rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
  yum install -y jenkins

  # firewall
  #firewall-cmd --permanent --new-service=jenkins
  #firewall-cmd --permanent --service=jenkins --set-short="Jenkins Service Ports"
  #firewall-cmd --permanent --service=jenkins --set-description="Jenkins Service firewalld port exceptions"
  #firewall-cmd --permanent --service=jenkins --add-port=8080/tcp
  #firewall-cmd --permanent --add-service=jenkins
  #firewall-cmd --zone=public --add-service=http --permanent
  #firewall-cmd --reload
  systemctl enable jenkins
  systemctl restart jenkins
  sleep 100
}

function configure_jenkins_server ()
{
  # Jenkins cli
  echo "installing the Jenkins cli ..."
  cp /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar /var/lib/jenkins/jenkins-cli.jar

  # Getting initial password
  # PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
  PASSWORD="${jenkins_admin_password}"
  sleep 10

  jenkins_dir="/var/lib/jenkins"
  plugins_dir="$jenkins_dir/plugins"

  cd $jenkins_dir

  # Open JNLP port
  xmlstarlet -q ed --inplace -u "/hudson/slaveAgentPort" -v 33453 config.xml

  cd $plugins_dir || { echo "unable to chdir to [$plugins_dir]"; exit 1; }

  # List of plugins that are needed to be installed 
  plugin_list="ssh-agent sonar codesonar build-with-parameters whitesource git-client git github-api github-oauth github MSBuild ssh-slaves workflow-aggregator ws-cleanup pipeline-maven aws-java-sdk docker-plugin docker-java-api chromedriver shiningpanda python nodejs backup pyenv-pipeline amazon-ecs
"

  # remove existing plugins, if any ...
  rm -rfv $plugin_list

#selenium needs

wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

yum localinstall google-chrome-stable_current_x86_64.rpm -y

wget https://chromedriver.storage.googleapis.com/2.41/chromedriver_linux64.zip
unzip chromedriver_linux64.zip

sudo mv chromedriver /usr/bin/chromedriver
sudo chown root:root /usr/bin/chromedriver
sudo chmod +x /usr/bin/chromedriver

pip install behave
pip install selenium
pip install virtualenv

# Python 3 installation
wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz
tar xJf Python-3.6.3.tar.xz
cd Python-3.6.3
./configure
make
sudo make install
sudo yum install python3-pip -y


  for plugin in $plugin_list; do
      echo "installing plugin [$plugin] ..."
      java -jar $jenkins_dir/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth admin:$PASSWORD install-plugin $plugin
  done

  sudo yum install -y amazon-efs-utils
  # sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-148a8195.efs.us-east-1.amazonaws.com:/ /var/lib/jenkins

  # Restart jenkins after installing plugins
  java -jar $jenkins_dir/jenkins-cli.jar -s http://127.0.0.1:8080 -auth admin:$PASSWORD safe-restart
}

### script starts here ###

install_packages

wait_for_jenkins

updating_jenkins_master_password

wait_for_jenkins

configure_jenkins_server

echo "Done"
exit 0
