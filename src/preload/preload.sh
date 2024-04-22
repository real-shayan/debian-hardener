#!/bin/bash

# This file installs the requirements.

# Check if you are really using Debian Bookworm:
ifDebian() {
    if [[ $(cat /etc/os-release | grep -E "Debian|bookworm") ]]; then
        CHECKDIST="Debian"
    fi

    if [ $CHECKDIST == "Debian" ]; then
        echo "Seems like you're using Debian 12 (Bookworm). Than's okay. Yay!"
    else
        echo "Oh No! We can't secure anything else Debian 12. Bye."
        exit 2
    fi
}

# Check if required packages are installed
ifInstalled() {
    if [[ $(dpkg --list | awk '$1=="ii" && /tripwire|apparmor|apparmor-utils|auditd|tcpd syslog-ng libpam-pwquality/') ]]; then
        echo "# Installing Dependencies ... "
        echo "# This should be done, Don't be worry, It's safe."
        sleep 4
        apt update
#        apt upgrade
        apt install auditd apparmor apparmor-utils tcpd syslog-ng libpam-pwquality ; clear
    fi
}
