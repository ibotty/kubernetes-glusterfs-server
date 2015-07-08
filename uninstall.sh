#!/bin/sh
chroot ${HOST} /usr/bin/systemctl disable /etc/systemd/system/glusterfs-server.service
rm -f ${HOST}/etc/systemd/system/glusterfs-server.service
