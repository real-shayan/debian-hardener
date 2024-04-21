#!/bin/bash
# Basic Hardening is Some Configurations like FileSystem Settings, Disabling Hardware access, etc.

# Disable Unused File Systems
source "src/preload/preload.sh"

if ! [ -d "src/rollback/rollback_files" ]; then
    mkdir -p "src/rollback/rollback_files"
fi

fsdisable() {
    echo "Removing & Disabling unused filesystems ... "
    sleep 1
    if [ -d /etc/modprobe.d ]; then
        echo "install freevxfs /bin/true" >/etc/modprobe.d/install-freevxfs.conf
        echo "install hfs /bin/true" >/etc/modprobe.d/install-hfs.conf
        echo "install hfsplus /bin/true" >/etc/modprobe.d/install-hfsplus.conf
        echo "install jffs2 /bin/true" >/etc/modprobe.d/install-jffs2.conf
        echo "install squashfs /bin/true" >/etc/modprobe.d/install-squashfs.conf
        echo "install udf /bin/true" >/etc/modprobe.d/install-udf.conf
        echo "Done!"
        return 0
    fi
}

# Disable USB Storage Access from the Kernel and Userland
usbdisable() {
    echo "Disabling USB Mass-Storage Access from the Kernel and Userland ... "
    sleep 2
    echo "blacklist usb-stoage" >/etc/modprobe.d/10-blacklist-usb.conf
    if ! [ -d "/etc/udev/rules.d" ]; then
        mkdir -p "/etc/udev/rules.d"
    fi
    UDEVPATH="/etc/udev/rules.d/10-disable-usb.rules"
    echo 'ACTION=="add", SUBSYSTEMS=="usb", TEST=="authorized_default", ATTR{authorized_default}="0"' >$UDEVPATH
    echo "Done!"
    return 0
}

# Disable tmpfs execution for users
fstabhardening() {
    echo "Disabling tmpfs Execution for users ... "
    sleep 1
    sed -i '/^tmpfs/d' /etc/fstab
    echo "tmpfs     /dev/shm    tmpfs   defaults,noexec,nodev,nosuid,seclabel   0   0" >>/etc/fstab
    echo "Done!"
    return 0
}

# Enable Sudoers Logging
sulogging() {
    echo "Enabling Sudoers logfile ..."
    sleep 1
    if ! [ -f "src/rollback/rollback_files/sudoers" ]; then
        cp /etc/sudoers src/rollback/rollback_files/sudoers
    fi

    LFPATH="/var/log/sudoers.log"
    if [ -f $LFPATH ]; then
        echo "The log file is already exist!"
        return 0
    else
        touch $LFPATH
        echo "Defaults      logfile=$LFPATH" >>/etc/sudoers
    fi
    echo "Done!"
    return 0
}

# Prevent users to modify or read another users files
umsk() {
    echo "Preventing users to modify or read another users files ..."
    sleep 1
    if ! [ -f ~/.profile ]; then
        touch ~/.profile
    fi
    echo "umask 077" >>~/.profile
    echo "Done!"
    return 0
}

pam() {
    echo "Updating PAM modules configurations ... "
    sleep 2
    LOGINDEFPATH="/etc/login.defs"
    LOGINDEF="files/pam/login.defs"
    COMMACC="files/pam/pam.d/common-account"
    COMMAUTH="files/pam/pam.d/common-auth"
    COMMPASS="files/pam/pam.d/common-password"

    # Min & Max Days for Changing Password
    sed -i '/^PASS_MAX_DAYS*/d' $LOGINDEFPATH
    sed -i '/^PASS_MIN_DAYS*/d' $LOGINDEFPATH
    echo "PASS_MAX_DAYS	90
PASS_MIN_DAYS	7" >>$LOGINDEFPATH

    # Ensuring that the users don't set past 5 passwords
    cat $COMMPASS >>/etc/pam.d/common-password

    # lock account after failed password auth attempt
    cat $COMMAUTH >>/etc/pam.d/common-auth
    cat $COMMACC >>/etc/pam.d/common-account
    echo "Done!"
    return 0
}

nethardening() {

    # Disable IPv6
    echo "Disabling IPv6 ..."
    sleep 1
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >/etc/sysctl.d/70-disable-ipv6.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >/etc/sysctl.d/71-disable-ipv6.conf
    echo "Done!"
    # Disable Unused Transport Layers
    echo "Disabling unused Transport Layers ..."
    sleep 1
    echo "install dccp /bin/false" >/etc/modprobe.d/disable-dccp.conf
    echo "install sctp /bin/false" >/etc/modprobe.d/disable-sctp.conf
    echo "install rds /bin/false" >/etc/modprobe.d/disable-rds.conf
    echo "install tipc /bin/false" >/etc/modprobe.d/disable-tipc.conf
    echo "Done!"
    return 0
    exit 0
}

pw() {
    # Password Quality
    echo "Changing Password Security Configurations ... "
    sleep 2
    PWPATH="/etc/security/pwquality.conf"
    PWFILE="files/pwquality/pwquality"
    cp $PWPATH "src/rollback/rollback_files/pwquality.conf"
    sed -i '/^minlen/d' $PWPATH
    sed -i '/^dcredit/d' $PWPATH
    sed -i '/^ucredit/d' $PWPATH
    sed -i '/^lcredit/d' $PWPATH
    cat $PWFILE >>$PWPATH
    echo "Done!"
    return 0
}

coredumps() {
    echo "Disabling Core Dumps ..."
    sleep 2
    # Disable Core Dumps
    COREDUMPPATH="/etc/security/limits.conf"
    echo "* 		hard 		core 		0" >>$COREDUMPPATH
    echo "Done!"
}

persistent() {
    echo "Setting up Systemd for Persistent logging ..."
    sleep 2
    # Set Systemd journald logging to Persistent
    sed -i '/^#Storage/d' /etc/systemd/journald.conf
    echo "Storage=persistent" >>/etc/systemd/journald.conf
    echo "Done!"
}

audit() {
    echo "Applying Auditd Configurations ..."
    AUDITPATH="/etc/audit/rules.d"
    if ! [ -d $AUDITPATH ]; then
        mkdir -p $AUDITPATH
    fi
    GRUBCFG="/etc/default/grub"
    sed -i 's/\(GRUB_CMDLINE_LINUX=*.*\)"/ \1 audit=1 audit_backlog_limit=8192"/' $GRUBCFG
    cat "files/auditd/record_date_time" >>$AUDITPATH/record_date_time.rules
    cat "files/auditd/record_initiation" >>$AUDITPATH/record_initiation.rules
    cat "files/auditd/record_login_logout" >>$AUDITPATH/record_login_logout.rules
    cat "files/auditd/record_mac_controls" >>$AUDITPATH/record_mac_controls.rules
    cat "files/auditd/record_networking" >>$AUDITPATH/record_networking.rules
    cat "files/auditd/record_user_group" >>$AUDITPATH/record_user_group.rules
    cat "files/auditd/record_dac_edit" >>$AUDITPATH/record_dac_edit.rules
    echo "Done!"
}

ungrouped() {
    # Ungrouped files should be assigned to 'root' group. It's safe and no need to revert/rollback.
    echo "Assigning ungrouped files to group ..."
    sleep 1
    GROUP='root'
    df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -ignore_readdir_race -nogroup -print 2>/dev/null | xargs chgrp "$GROUP"
    echo "Done!"
}

unowned() {
    # Unowned files should be assigned to 'user'. It's safe and no need to revert/rollback.
    echo "Assigning unowned files to user ..."
    sleep 1
    df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -ignore_readdir_race -nouser -print 2>/dev/null | xargs chown "$USER"
    echo "Done!"
}

icmpredirect() {
    # Disable ICMP Send Redirects
    echo "Disabling ICMP Send Redirects ..."
    sleep 1
    SYSCTLPATH="/etc/sysctl.d/99-sysctl.conf"
    echo "net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv6.conf.all.send_redirects = 0
net.ipv6.conf.default.send_redirects = 0
" >> $SYSCTLPATH
    sysctl -w net.ipv4.conf.all.send_redirects=0
    sysctl -w net.ipv4.conf.default.send_redirects=0
    sysctl -w net.ipv4.route.flush=1 >/dev/null
    echo "Done!"
}