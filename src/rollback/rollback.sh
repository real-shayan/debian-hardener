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
rm /etc/modprobe.d/install-*
echo "Done!"


# Enabling USB Storage Access
echo "Rolling Back USB Mass-Storage Hardening ..."
sleep 1
if [ -f /etc/modprobe.d/10-blacklist-usb ]; then
    rm /etc/modprobe.d/10-blacklist-usb.conf
    rm /etc/udev/rules.d/10-disable-usb.rules
    echo "Done!"
    return 0
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
rm /var/log/sudoers.log
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
cp src/rollback/rollback_files/pwquality.conf /etc/security/pwquality.conf
echo "Done!"

# Uninstall Installed Packages by this script: 
apt remove tripwire apparmor apparmor-utils