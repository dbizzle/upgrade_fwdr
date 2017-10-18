#!/bin/bash

# leave disabled, logged elsewhere
#exec > >(tee -i upgrade.log) 2>&1

# set splunk path
SPLUNK_HOME=/opt/splunkforwarder

# set desired version
NVER=6.5.2

# determine current version
CVER=`cat $SPLUNK_HOME/etc/splunk.version | grep VERSION | cut -d= -f2`

# get hostname and GUID and PID
HOSTNAME=`cat $SPLUNK_HOME/var/log/splunk/splunkd.log | grep -m 1 'My server name is' | cut -d'"' -f2`
GUID=`cat $SPLUNK_HOME/etc/instance.cfg | grep guid | cut -d' ' -f3`
PID1=`$SPLUNK_HOME/bin/splunk status | grep "is running" |grep -o '[0-9]*'`


# we've got 32bit and 64bit platforms, upgrade if needed
PLATFORM=`file $SPLUNK_HOME/bin/splunk | cut -d ' ' -f3`

case $PLATFORM in
		64-bit )
			if [[ "$NVER" != "$CVER" ]]; 
			then
			   	echo "$HOSTNAME,$GUID,$CVER,$PLATFORM,$PID1,Upgrading Splunk to $NVER"
			   	sleep 10
  				$SPLUNK_HOME/bin/splunk stop
   				tar -xvf $SPLUNK_HOME/etc/apps/upgrade_linux_uf/static/splunkforwarder-6.5.2-67571ef4b87d-Linux-x86_64.tgz -C /opt
   				$SPLUNK_HOME/bin/splunk start --accept-license --answer-yes
   			else
   				echo "$HOSTNAME,$GUID,$CVER,$PLATFORM,$PID1,Nothing to do!"
   			fi
			;;
		32-bit )
			if [[ "$NVER" != "$CVER" ]];
			then
				echo "$HOSTNAME,$GUID,$CVER,$PLATFORM,$PID1,Upgrading Splunk to $NVER"
				sleep 10
   				$SPLUNK_HOME/bin/splunk stop 
   				tar -xvf $SPLUNK_HOME/etc/apps/upgrade_linux_uf/static/splunkforwarder-6.5.2-67571ef4b87d-Linux-i686.tgz -C /opt
   				$SPLUNK_HOME/bin/splunk start --accept-license --answer-yes
   			else
   				echo "$HOSTNAME,$GUID,$CVER,$PLATFORM,$PID1,Nothing to do!"
   			fi
			;;
		* ) 
			echo "$HOSTNAME,$GUID,$PLATFORM,$CVER,$PID1,Bad Platform?"
			break
			;;			
esac

# do some kind of validation
sleep 5
PID2=`$SPLUNK_HOME/bin/splunk status | grep "is running" |grep -o '[0-9]*'`
CVER=`cat $SPLUNK_HOME/etc/splunk.version | grep VERSION | cut -d= -f2`
PLATFORM=`file $SPLUNK_HOME/bin/splunk | cut -d ' ' -f3`

if [[ "$CVER" = "$NVER" && "PID1" != "$PID2" ]]; then
	echo "$HOSTNAME,$GUID,$CVER,$PLATFORM,$PID2,Splunk is running."
else
	echo "$HOSTNAME,$GUID,$CVER,$NVER,$PLATFORM,$PID1,$PID2,Something went wrong."
fi
