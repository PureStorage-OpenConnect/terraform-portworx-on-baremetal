#!/bin/bash

#########################
# The command line help #
#########################
display_help() {
  echo "$(date) --> Usage: $0 [optional app] [aws|gcloud|azure] " >&2
  echo "$(date) -->        for example: ./prereq.sh [aws] "
  echo "$(date) -->        for example: ./prereq.sh [gcloud] "
  echo
  exit 1
}

source ~/.bashrc

if [[ "$(uname -s)" == Linux ]]; then
  vRETURN=$(grep "^NAME=" /etc/os-release| cut -f2 -d"=")
  if [[ ${vRETURN} == '"CentOS Linux"' ]]; then
    LINUX_DISRO="CENTOS"
  elif [[ ${vRETURN} == '"Ubuntu"' ]]; then
    LINUX_DISRO="UBUNTU"
  else
    LINUX_DISRO="CENTOS"
    #echo -e "Unsupported Linux Distribution. Currenty CentOS and Ubuntu are supported. \nPlease install all the tools as per the documentation for your linux distribution"
    #exit 1;
  fi
elif [[ "$(uname -s)" == Darwin ]]; then 
  echo 'Darwin (MacOS) Detected.'
else
  echo -e "Unsupported operating system. Currenty MAC and Linux (CentOS, Ubuntu) are supported."
  exit 1;
fi

installBasicUtils() {
  if [[ "$(uname -s)" == Linux ]]; then
    if [[ "${LINUX_DISRO}" == "CENTOS" ]]; then
      echo "Installing basic tools -- on Linux OS (CentOS)--> "
      #sudo yum check-update
      sudo yum install unzip curl wget git -qy
    else
      echo "Installing basic tools -- on Linux OS (Ubuntu)--> "
      sudo apt-get update;
      sudo apt-get install unzip curl wget git -qy
    fi
  elif [[ "$(uname -s)" == Darwin ]]; then 
    echo 'Installing basic tools -- on Darwin (MacOS) -->'
    brew install unzip curl wget git
  fi
  echo 'Installing basic tools completed.'
}

installTerraform() {
  if ! terraform -version; then
    echo "Terraform not found.. installing now.."
    if [[ "$(uname -s)" == Darwin ]]; then 
      wget -q -O/tmp/terraform.zip https://releases.hashicorp.com/terraform/1.3.5/terraform_1.3.5_darwin_amd64.zip
    elif [[ "$(uname -s)" == Linux ]]; then
      wget -q -O/tmp/terraform.zip https://releases.hashicorp.com/terraform/1.3.5/terraform_1.3.5_linux_amd64.zip 
    fi
    sudo unzip -q -d /usr/local/bin /tmp/terraform.zip 
    rm /tmp/terraform.zip
    echo 'Terrafrom installation completed'
  else
    echo 'Terrform found, no updates are made..'
  fi
}

installDocker() {
  echo 'Checking Docker...'
  if ! docker -v; then
    if [[ "$(uname -s)" == Linux ]]; then
      # Install Docker
      if [[ "${LINUX_DISRO}" == "UBUNTU" ]]; then
        sudo apt-get install -qy uidmap
      fi
      curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
      sudo sh /tmp/get-docker.sh
      echo "user.max_user_namespaces = 28633" | sudo tee -a /etc/sysctl.d/51-rootless.conf
      sudo sysctl --system
      dockerd-rootless-setuptool.sh install
      echo "export DOCKER_HOST=unix:///run/user/$(id -ru)/docker.sock" >> ~/.bashrc
    elif [[ "$(uname -s)" == Darwin ]]; then 
      echo "Docker not found.. installing now on Darwin (MacOS).."
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      echo 'Docker Installation is completed...'
    fi
  else
      echo 'Docker found.. no updates are made'
  fi
}

installGIT() {
  echo 'Checking GIT version'
  if ! git --version; then
    echo 'GIT not found.. installing now on Darwin (MacOS)...'
    if [[ "$(uname -s)" == Darwin ]]; then 
      brew install git
    fi
  else
    echo 'GIT found. no updates are made'
  fi
}

installKubeCTL() {
  echo 'Checking kubectl version'
    if ! kubectl version --client=true; then
    echo "kubectl not found.. installing now.."
    if [[ "$(uname -s)" == Linux ]]; then
      curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /tmp/kubectl
      sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
    elif [[ "$(uname -s)" == Darwin ]]; then 
      brew install kubectl
    fi
    echo 'kubectl Installation is completed...'
  else
    echo 'kubectl found.. no updates are made'
  fi
}

installHelm() {
  echo 'Checking Helm version'
  if ! helm version; then
    echo "Helm not found.. installing now.."
    if [[ "$(uname -s)" == Linux ]]; then
      curl -fsSL -o get_helm.sh "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
      sudo chmod 700 get_helm.sh
      sudo ./get_helm.sh
    elif [[ "$(uname -s)" == Darwin ]]; then
      brew install helm 
    fi
    echo 'Helm Installation is completed...'
  else
    echo 'Helm found.. no updates are made'
  fi
}


installJQ() {
  echo 'Checking JQ version'
    if ! jq --version; then
    echo "JQ not found.. installing now.."
    if [[ "$(uname -s)" == Linux ]]; then
      if [[ "${LINUX_DISRO}" == "CENTOS" ]]; then
        sudo yum install jq -qy
      elif [[ "${LINUX_DISRO}" == "UBUNTU" ]]; then
        sudo apt-get install jq -qy
      fi
    elif [[ "$(uname -s)" == Darwin ]]; then 
      brew install jq
    fi
    echo 'JQ Installation is completed...'
  else
    echo 'JQ found.. no updates are made'
  fi
}

install_pip3() {
  echo 'Checking pip3 version'
    if ! pip3 --version; then
    echo "pip3 not found.. installing now.."
    if [[ "$(uname -s)" == Linux ]]; then
      if [[ "${LINUX_DISRO}" == "CENTOS" ]]; then
        sudo yum install python3-pip -qy
      elif [[ "${LINUX_DISRO}" == "UBUNTU" ]]; then
        sudo apt-get install python3-pip -qy
      fi
    elif [[ "$(uname -s)" == Darwin ]]; then 
      brew install python3
    fi
    echo 'pip3 Installation is completed...'
  else
    echo 'pip3 found.. no updates are made'
  fi
}

checkRqdAppsAndVars() {
  #Check required Apps - 
  if ! kubectl version --client > /dev/null 2>&1; then
     echo "KubeCTL Missing"
  else
     echo "KubeCTL found"
  fi
  if ! jq --version; then
     echo "jq Missing"
  else
     echo "jq found"
  fi
  if ! pip3 --version > /dev/null 2>&1; then
     echo "pip3 Missing"
  else
     echo "pip3 found"
  fi

  if ! git --version > /dev/null 2>&1; then
    echo "GIT Missing"
  else
     echo "GIT found"
  fi

  if ! docker -v > /dev/null 2>&1; then
    echo "Docker Missing" 
  else
     echo "Docker found"
  fi

  if ! helm version > /dev/null 2>&1; then
    echo "Helm Missing"
  else
     echo "Helm found"
  fi

  if ! terraform -version > /dev/null 2>&1; then
    echo "Terraform Missing"
  else
     echo "Terraform found"
  fi

  source ~/.bashrc

  exit 0;
}

ARG1=$1

if [[ $ARG1 = "help"  ]]; then
    display_help
elif [[ $ARG1 = "check" ]]; then
  checkRqdAppsAndVars
  exit 0;
fi

echo "$(date) - Started"
echo ''
installBasicUtils
echo ''
installGIT
echo ''
installKubeCTL
echo ''
installJQ
echo ''
install_pip3
echo ''
installTerraform
echo ''
installHelm

echo "$(date) - Script completed successfully"

echo -e "\n\n\n$(date) - To make sure all the tools are available, run following command:\n\nsource ~/.bashrc"
