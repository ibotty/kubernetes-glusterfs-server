FROM fedora:23
MAINTAINER Tobias Florek tob@butter.sh

# gluster ports: daemon, infiniband, brick 1-100
EXPOSE 24007 24008 49152-49251

# nfs ports and portmapper
#EXPOSE 2049 38465-38467 111/udp 111

ENV GLUSTER_VERSION 3.7

RUN curl -o /etc/yum.repos.d/glusterfs-fedora.repo \
    https://download.gluster.org/pub/gluster/glusterfs/${GLUSTER_VERSION}/LATEST/Fedora/glusterfs-fedora.repo \
 && rpmkeys --import https://download.gluster.org/pub/gluster/glusterfs/${GLUSTER_VERSION}/LATEST/Fedora/pub.key \
 && dnf --setopt=tsflags=nodocs -y install \
        attr \
        lvm2 \
        xfsprogs \
        glusterfs-server \
        glusterfs-geo-replication \
        glusterfs-extra-xlators \
 && dnf clean all

ADD install.sh uninstall.sh entrypoint.sh new-brick.sh new-volume.sh /bin/
ADD mount.glusterfs-wrapper /root/

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["daemon"]
VOLUME ["/etc/glusterfs", "/var/lib/glusterd"]

LABEL INSTALL="docker run --rm --privileged --entrypoint /bin/sh -v /:/host -e HOST=/host -e LOGDIR=\${LOGDIR} -e CONFDIR=\${CONFDIR} -e DATADIR=\${DATADIR} -e IMAGE=IMAGE -e NAME=NAME IMAGE /bin/install.sh"
LABEL UNINSTALL="docker run --rm --privileged --entrypoint /bin/sh -v /:/host -e HOST=/host -e IMAGE=IMAGE -e NAME=NAME IMAGE /bin/uninstall.sh"
LABEL RUN="docker exec -it --rm --privileged -p 24007-24008:24007-24008/tcp -p 49152-49251:49152-49251/tcp --ipc host -v /dev/mapper:/dev/mapper -v /dev/fedora:/dev/fedora -v /etc/lvm:/etc/lvm -v /run/lvm:/run/lvm -v /etc/glusterfs:/etc/glusterfs -v /run/systemd/journal/dev-log:/dev/log -n NAME IMAGE bash"
# TODO: /dev/fedora should be /dev/${GLUSTER_VG}
LABEL USAGE="docker exec -it --rm --privileged IMAGE usage"
