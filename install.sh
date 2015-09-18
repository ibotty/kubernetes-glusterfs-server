#!/bin/sh

if [ ! -d ${HOST}/etc/glusterfs ]; then
    cp -a /etc/glusterfs ${HOST}/etc/glusterfs
fi

mkdir -p ${HOST}/var/lib/glusterd
mkdir -p ${HOST}/var/usrsbin
mkdir -p ${HOST}/var/usrsbin_work

cp /root/mount.glusterfs-wrapper ${HOST}/var/usrsbin/mount.glusterfs


cat <<EOF > ${HOST}/etc/systemd/system/glusterfs-server.service
[Unit]
Description=Gluster Daemon running in ${NAME}
After=docker.service
Requires=docker.service
Wants=sbin-overlay.service

[Service]
ExecStart=/usr/bin/docker run --rm --privileged --net host -v /var/lib/glusterd:/var/lib/glusterd -v /var/data/glusterfs:/data/glusterfs -v /etc/glusterfs:/etc/glusterfs -v /run/systemd/journal/dev-log:/dev/log --name ${NAME} ${IMAGE} daemon
ExecStop=/usr/bin/docker stop ${NAME}

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > ${HOST}/etc/systemd/system/sbin-overlay.service
[Unit]
Description=Mounts an overlay fs over /sbin

[Service]
ExecStart=/bin/mount -t overlay overlay /sbin -o lowerdir=/usr/sbin,upperdir=/var/usrsbin,workdir=/var/usrsbin_work
ExecStop=/bin/umount -t overlay /sbin
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
