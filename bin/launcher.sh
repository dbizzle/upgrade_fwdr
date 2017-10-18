#!/bin/bash

#exec > >(tee -i /opt/splunkforwarder/etc/apps/upgrade_linux_uf/bin/script.log) 2>&1

echo upgrade_linux_uf wrapper.sh Starting >&2

( /opt/splunkforwarder/etc/apps/upgrade_linux_uf/bin/upgrade.sh )& 
