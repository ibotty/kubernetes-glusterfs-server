FROM centos:7
MAINTAINER Tobias Florek tob@butter.sh

# gluster ports: daemon, infiniband, brick 1-100
EXPOSE 24007 24008 49152-49251

# nfs ports and portmapper
EXPOSE 2049 38465-38467 111/udp 111

ENV GLUSTER_VERSION 3.7
ENV container docker
ENV HOST /host

ADD libexec/* /usr/libexec/gluster-container/
ADD bin/* /usr/bin/
ADD *.service /etc/systemd/system/
#ADD mount.glusterfs-wrapper /root/

RUN rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
 && yum --setopt=tsflags=nodocs -y install centos-release-gluster37 \
 && rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage \
 && yum --setopt=tsflags=nodocs -y install \
        xfsprogs \
        glusterfs-storage-setup \
        glusterfs-server \
        glusterfs-geo-replication \
        glusterfs-extra-xlators \
        glusterfs-coreutils \
        glusterfs-ganesha \
 && yum clean all \
 && rm /etc/systemd/system/*.wants/* /lib/systemd/system/*.wants/* \
 && chmod -x /usr/lib/systemd/system/glusterd.service \
 && systemctl enable glusterd glusterfsd glusterfs-container-setup \
                     glusterfs-storage-setup systemd-journald #nfs-ganesha \
 #                    rsyslog crond

# crond is enabled for log rotating /var/log/glusterfs

CMD ["/sbin/init"]
VOLUME ["/etc/glusterfs", "/var/lib/glusterd", "/sys/fs/cgroup", "/var/log/glusterfs"]

#LABEL INSTALL="docker run --rm --privileged -v /:/host -e HOST=/host -e LOGDIR=\${LOGDIR} -e CONFDIR=\${CONFDIR} -e DATADIR=\${DATADIR} -e IMAGE=IMAGE -e NAME=NAME IMAGE /usr/libexec/gluster-container/install
#LABEL UNINSTALL="docker run --rm --privileged -v /:/host -e HOST=/host -e IMAGE=IMAGE -e NAME=NAME IMAGE /usr/libexec/gluster-container/uninstall
#LABEL RUN="docker exec -it --rm --privileged -p 24007-24008:24007-24008/tcp -p 49152-49251:49152-49251/tcp --ipc host -v /dev/mapper:/dev/mapper -v /dev/fedora:/dev/fedora -v /etc/lvm:/etc/lvm -v /run/lvm:/run/lvm -v /etc/glusterfs:/etc/glusterfs -v /run/systemd/journal/dev-log:/dev/log -n NAME IMAGE bash"
#LABEL USAGE="docker exec -it --rm IMAGE usage"
