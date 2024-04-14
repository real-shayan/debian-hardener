#!/bin/bash

# AppArmor Enablement
apparmorhardening() {
    GRUBCFG="/etc/default/grub"
    # Add Parameters in CMDLINE
    sed -i 's/\(GRUB_CMDLINE_LINUX=*.*\)"/ \1 apparmor=1 security=apparmor"/' $GRUBCFG
    # UNDER MAINTAIN #
}