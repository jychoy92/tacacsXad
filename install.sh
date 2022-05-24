#!/bin/bash

####
# Installation Instructions
#
# wget https://github.com/jychoy92/tacacsXad/raw/main/install.sh -O install.sh; bash install.sh
#
####

## TEXT OUTPUT COLORS
NORMAL="\e[0m"
BLUE="\e[94m"
CYAN="\e[96m"
RED="\e[91m"
MAGENTA="\e[35m"
LGREEN="\e[92m"
GREEN="\e[32m"
ITALIC="\e[3m"

## Installation Repo URL
INSTALL_REPO="https://github.com/jychoy92/tacacsXad.git"

function update_server() {
    echo ''
    echo -e "${CYAN}Updating OS packages ...${NORMAL}"
    echo ''
    sudo apt clean all;
    sudo apt update;
    sudo apt --yes dist-upgrade;
    sudo apt --yes autoremove
}

function install_ansible() {
    echo ''
    echo -e "${CYAN}Installing Ansible packages ...${NORMAL}"
    echo ''
    sudo apt install --yes ansible;
}

function clone_install_repo() {

    if [ -d "tacacsXad" ]; then
        rm -fr "tacacsXad";
    fi
    echo ''
    echo -e "${CYAN}Downloading tacacsXad Ansible Playbooks ...${NORMAL}"
    echo ''
    git clone ${INSTALL_REPO};

}

function start_tacacs_installation() {
    echo ''
    echo -e "${CYAN}Initiating TACACS+ Installation ...${NORMAL}"

    echo -e "${BLUE}LDAP Server IP (e.g.: 10.2.10.101)${NORMAL}"
    until [[ $ldap_server_ip ]]; do read -p "> " ldap_server_ip; done
    echo -e "${BLUE}LDAP Search Base DN (e.g.: OU=Guardians,DC=sg,DC=sea,DC=local)${NORMAL}"
    until [[ $ldap_base_dn ]]; do read -p "> " ldap_base_dn; done
    echo -e "${BLUE}LDAP Query Service Account ID (e.g.: srv-tacacs@sg.sea.local)${NORMAL}"
    until [[ $ldap_auth_username ]]; do read -p "> " ldap_auth_username; done
    echo -e "${BLUE}LDAP Query Service Account Password${NORMAL}"
    until [[ $ldap_auth_password ]]; #do read -sp "> " ldap_auth_password; done
    
    while read -sp "> " ldap_auth_password -r -s -n 1 char
        do
            if [[ $char == $'\0' ]]
            then
                break
            fi
            prompt='*'
            password+="$char"
    done
    
    
    echo ''
    echo -e "${BLUE}Tacacs Admin AD Security Group Name (e.g.: TACACS-Admin)${NORMAL}"
    until [[ $tacacs_admin_group ]]; do read -p "> " tacacs_admin_group; done
    echo -e "${BLUE}Tacacs Helpdesk AD Security Group Name (e.g.: TACACS-Helpdesk)${NORMAL}"
    until [[ $tacacs_helpdesk_group ]]; do read -p "> " tacacs_helpdesk_group; done
    echo -e "${BLUE}Tacacs Read Only AD Security Group Name (e.g.: TACACS-ReadOnly)${NORMAL}"
    until [[ $tacacs_readonly_group ]]; do read -p "> " tacacs_readonly_group; done
    echo -e "${BLUE}Tacacs Encryption Key (e.g.: SEAtacacs)${NORMAL}"
    until [[ $tacacs_encryption_key ]]; do read -sp "> " tacacs_encryption_key; done
    echo ''
    echo -e "${BLUE}Network Devices Management Subnet (e.g.: 10.61.0.0/16)${NORMAL}"
    until [[ $network_mgmt_subnet ]]; do read -p "> " network_mgmt_subnet; done

    echo ''

    ansible-playbook -i hosts playbooks/install_tacacs.yml \
     -e "ldap_server_ip=${ldap_server_ip}" \
     -e "ldap_base_dn=${ldap_base_dn}" \
     -e "ldap_auth_username=${ldap_auth_username}" \
     -e "ldap_auth_password=${ldap_auth_password}" \
     -e "tacacs_admin_group=${tacacs_admin_group}" \
     -e "tacacs_helpdesk_group=${tacacs_helpdesk_group}"\
     -e "tacacs_readonly_group=${tacacs_readonly_group}"\
     -e "tacacs_encryption_key=${tacacs_encryption_key}"\
     -e "network_mgmt_subnet=${network_mgmt_subnet}";
}


## Main Processing Function
## This function calls all the primary execution functions

function main() {

    cd /root

    update_server
    install_ansible
    clone_install_repo

    cd /root/tacacsXad/
    start_tacacs_installation
}


## BEGIN SCRIPT PROCESS
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root user.${NORMAL}" 
   exit 1
else
    # Start installation process
    echo ''
    echo -e "${CYAN}Starting the installation process ...${NORMAL}"
    main

    # Installation complete
    echo ''
    echo -e "${GREEN}Installation has been completed.${NORMAL}"
    echo ''
fi

