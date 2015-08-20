#!/bin/sh

if [ ! -d ${HOST}/etc/glusterfs ]; then
    cp -a /etc/glusterfs.default ${HOST}/etc/glusterfs
fi

mkdir -p ${HOST}/var/lib/glusterd

cat <<EOF > ${HOST}/etc/systemd/system/glusterfs-server.service
[Unit]
Description=Gluster Daemon running in ${NAME}
After=docker.service

[Service]
ExecStart=/usr/bin/docker run --rm --privileged --net host -v /var/lib/glusterd:/var/lib/glusterd -v /var/data/glusterfs:/data/glusterfs -v /etc/glusterfs:/etc/glusterfs -v /run/systemd/journal/dev-log:/dev/log --name ${NAME} ${IMAGE} daemon
ExecStop=/usr/bin/docker stop ${NAME}

[Install]
WantedBy=multi-user.target
EOF
