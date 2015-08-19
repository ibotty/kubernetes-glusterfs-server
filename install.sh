#!/bin/sh

if [ ! -d ${HOST}/etc/glusterfs ]; then
    cp -a /etc/glusterfs.default ${HOST}/etc/glusterfs
fi

cat <<EOF > ${HOST}/etc/systemd/system/glusterfs-server.service
[Unit]
Description=Gluster Daemon running in ${NAME}
After=docker.service

[Service]
ExecStart=/usr/bin/docker run --rm --privileged -p 24007-24008:24007-24008/tcp -p 49152-49161:49152-49161/tcp -v /var/data/glusterfs:/data/glusterfs -v /etc/glusterfs:/etc/glusterfs -v /run/systemd/journal/dev-log:/dev/log --name ${NAME} ${IMAGE} daemon
ExecStop=/usr/bin/docker stop ${NAME}

[Install]
WantedBy=multi-user.target
EOF
