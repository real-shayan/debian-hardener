#!/bin/bash
# CIS Hardening Automatic Script
# for Debian GNU/Linux 12 (Bookworm)
# Author: Shayan Karimi Shiraz

# Should be Run as Root
if [[ $EUID -ne 0 ]]; then
    echo "$0 is not running as root. Exiting ..."
    exit 2
fi

SRCPATH="src/hardening"
source src/preload/preload.sh
source $SRCPATH/basic.sh
source $SRCPATH/advanced.sh

# Main Options
case $1 in
-v | --version) echo "Irancell-Hardener-v0.1" ;;
-h | --help) echo "Welcome to Irancell Hardener. With this script, you can secure your debian destribution.

Usage: 
    -b | --basic         - Secure the Basic things
    -a | --advanced      - Secure the higher level
    -r | --rollback      - Rollback Previous Changes
    -h | --help          - Show Available Options
    -v | --version       - Show Version Information" ;;
-a | --advanced) echo "On Going ... Use --basic for now." ;;
-b | --basic)
ifDebian
ifInstalled
fsdisable
usbdisable
fstabhardening
sulogging
umsk
nethardening
pw
coredumps
persistent
audit
ungrouped
unowned
icmpredirect
martian
echo "Done!"  ;;
-r | --rollback) sh -c src/rollback/rollback.sh ;;
*)
    echo "Irancell-Hardener - a Simple Script for making the debian more Secure. 
Invalid option. use --help for more details."
    ;;
esac