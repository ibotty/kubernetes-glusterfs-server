#!/bin/sh

if [ ! -d ${HOST}/etc/glusterfs ]; then
    cp -a /etc/glusterfs ${HOST}/etc/glusterfs
fi

mkdir -p ${HOST}/var/lib/glusterd
mkdir -p ${HOST}/var/usrsbin
mkdir -p ${HOST}/var/usrsbin_work

cp /root/mount.glusterfs-wrapper ${HOST}/var/usrsbin/mount.glusterfs

if [ ! -f /etc/sysconfig/glusterfs-server ]; then
    cat <<EOF > ${HOST}/etc/sysconfig/glusterfs-server
GLUSTER_VG=fedora
GLUSTER_POOL=gluster-pool
EOF
fi

cat <<EOF > ${HOST}/etc/systemd/system/glusterfs-server.service
[Unit]
Description=Gluster Daemon running in ${NAME}
After=docker.service
Requires=docker.service
Wants=sbin-overlay.service

[Service]
EnvironmentFile=/etc/sysconfig/glusterfs-server
ExecStart=/usr/bin/docker run --stop-signal SIGPWR --rm --privileged --ipc host --net host -v /sys/fs/cgroups:/sys/fs/cgroups:ro -v /dev/mapper:/dev/mapper -v /dev/\${GLUSTER_VG}:/dev/\${GLUSTER_VG} -v /etc/lvm:/etc/lvm -v /run/lvm:/run/lvm -v /var/lib/glusterd:/var/lib/glusterd -v /etc/glusterfs:/etc/glusterfs -v /run/systemd/journal/dev-log:/dev/log -e GLUSTER_VG=\${GLUSTER_VG} -e GLUSTER_POOL=\${GLUSTER_POOL} --name ${NAME} ${IMAGE}
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
