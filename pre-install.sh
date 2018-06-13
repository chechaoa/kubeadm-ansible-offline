#!/bin/bash

# Copyright 2018 The Caicloud Authors All rights reserved.

set -o errexit
set -o nounset

INVENTORY_FILE_NAME=inventory


echo ""
echo "### create local.repo"
./add_repo.sh

OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o "\w*"| head -n 1)

  case "${OS_NAME}" in
    "CentOS")
      sudo yum install -y ansible
    ;;
    "Ubuntu")
      sudo sed -i 's/us.archive.ubuntu.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
      sudo apt-get update && sudo apt-get install -y ansible 
    ;;
    *)
      echo "${OS_NAME} is not support ..."; exit 1
  esac


###close private key check
export ANSIBLE_HOST_KEY_CHECKING=False

echo ""
echo "#### 设置免密码认证"
./addkey.sh


echo ""
echo "#### Make sure your inventory file is correct!"
cat ${INVENTORY_FILE_NAME}

echo ""
echo "#### Setup k8s cluster"
ansible-playbook -i ${INVENTORY_FILE_NAME} site.yml
