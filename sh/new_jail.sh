#!/bin/sh
#
# Script to set up a new FreeBSD jail based on the layout found in TFH:
# http://www5.us.freebsd.org/doc/handbook/jails-application.html
#

if test -z $JAIL; then
	echo "Environment variable JAIL must be set"
	exit 1
fi

if test -z $IP; then
	echo "Environment variable IP must be set"
	exit 1
fi

echo "Creating $JAIL with IP $IP"

cpdup /storage/jails/skel /storage/jails/$JAIL
mkdir /storage/jails/${JAIL}_ro

echo "/storage/jails/root /storage/jails/${JAIL}_ro nullfs ro 0 0" >> /etc/fstab
echo "/storage/jails/${JAIL} /storage/jails/${JAIL}_ro/s nullfs rw 0 0" >> /etc/fstab
echo "/usr/ports /storage/jails/${JAIL}_ro/usr/ports nullfs noatime,rw 0 0" >> /etc/fstab

echo "jail_${JAIL}_hostname=\"${JAIL}\"" >> /etc/rc.conf
echo "jail_${JAIL}_ip=\"${IP}\"" >> /etc/rc.conf
echo "jail_${JAIL}_rootdir=\"/storage/jails/${JAIL}_ro\"" >> /etc/rc.conf
echo "jail_${JAIL}_devfs_enable=\"YES\"" >> /etc/rc.conf
