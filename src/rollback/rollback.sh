#!/bin/bash
# RollBack Feature for Irancell Hardener
# Note: This is under maintain for improvement, but stil works.

# Should be Run as Root
if [[ $EUID -ne 0 ]]; then
    echo "$0 is not running as root. Exiting ..."
    exit 2
fi

clear
# Rollback FS
echo "Rolling Back File System Hardening ..."
sleep 1
if [ -f "/etc/modprobe.d/install-hfs.conf" ]; then
    rm /etc/modprobe.d/install-*
else
    echo "It's already Rolled Back! Ignoring ..."
fi
echo "Done!"


# Enabling USB Storage Access
echo "Rolling Back USB Mass-Storage Hardening ..."
sleep 1
if [ -f /etc/modprobe.d/10-blacklist-usb.conf ]; then
    rm /etc/modprobe.d/10-blacklist-usb.conf
    rm /etc/udev/rules.d/10-disable-usb.rules
    echo "Done!"
fi

# Rollback fstab
echo "Rolling Back fstab ..."
sleep 1
sed -i '/^tmpfs/d' /etc/fstab
echo "Done!"

# Rollback Sudoers
echo "Rolling Back Sudoers Policy Configurations ..."
if [ -f "src/rollback/rollback_files/sudoers" ]; then
    cp src/rollback/rollback_files/sudoers /etc/sudoers
fi
echo "Flushing sudoer logs"
sleep 1
if [ -f "/var/log/sudoers.log" ]; then
    rm /var/log/sudoers.log
fi
echo "Done!"

# Rollback Umask
echo "Reverting Umask Configuration ..."
sleep 1
sed -i '/^umask/d' ~/.profile
echo "Done!"


# Rollback Network Settings 
echo "Enabling IPv6 ..."
IPV6C1="/etc/sysctl.d/70-disable-ipv6.conf"
IPV6C2="/etc/sysctl.d/71-disable-ipv6.conf"
sleep 1
if [ -f $IPV6C1 ]; then
    rm $IPV6C1
else
    echo "It's not even enabled, Skipping ..."
fi
if [ -f $IPV6C2 ]; then
    rm $IPV6C2
else
    echo "It's not even enabled, Skipping ..."
fi
echo "Done!"

# Rollback Transport Layers 
echo "Enabling Unused Transport Layers ..."
sleep 1
if [ `ls -l /etc/modprobe.d/disable-* 2>/dev/null | wc -l ` -gt 0 ]; then 
    rm "/etc/modprobe.d/disable-dccp.conf"
    rm "/etc/modprobe.d/disable-sctp.conf"
    rm "/etc/modprobe.d/disable-rds.conf"
    rm "/etc/modprobe.d/disable-tipc.conf"
    echo "Done!"
else
    echo "Seems like there is no rules. Ignoring ..."
fi

# Rollback PW Settings
echo "Rolling Back Password Quality Configurations ..."
sleep 1
PWSRC="src/rollback/rollback_files/pwquality.conf"
if [ -f $PWSRC ]; then
    cp src/rollback/rollback_files/pwquality.conf /etc/security/pwquality.conf
fi
echo "Done!"

# Uninstall Installed Packages by this script: 
apt remove tripwire apparmor apparmor-utils

# Enable Core Dumps
echo "Rolling Back Core Dumps Settings ..."
sleep 1
sed -i '$ d' /etc/security/limits.conf
echo "Done!"

# Rollback Systemd Journald Settings
echo "Rolling Back Systemd Journald Settings to default ... "
sleep 1
sed -i '/^#Storage/d' /etc/systemd/journald.conf
echo "#Storage=auto" >>/etc/systemd/journald.conf
echo "Done!"

# Rollback auitd cconfigurations
AUDITPATH="/etc/audit/rules.d"
echo "Rolling Back Auditd Configurations ..."
sleep 1
rm $AUDITPATH/*
echo "Done!"

# Rollback sshd_config
SSHDCONF="/etc/ssh/sshd_config"
echo "Rolling Back SSH Configurations ..."
sleep 3
sed -i '/^KerberosAuth/d' $SSHDCONF
sed -i '/^ChallengeRespon/d' $SSHDCONF
sed -i '/^HostBasedAuth/d' $SSHDCONF
sed -i '/^GSSAPIAuth/d' $SSHDCONF
sed -i '/^GSSAPIKeyEx/d' $SSHDCONF
sed -i '/^PasswordAuthentication/d' $SSHDCONF
sed -i '/^Pubkey/d' $SSHDCONF
echo "PubkeyAuthentication no
PasswordAuthentication yes" >> $SSHDCONF
echo "Done!"