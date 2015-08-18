FROM fedora:22
MAINTAINER Tobias Florek tob@butter.sh

# gluster ports: daemon, infiniband, brick 1-10 
EXPOSE 24007 24008 49152-49161

# nfs ports and portmapper
#EXPOSE 2049 38465-38467 111/udp 111

VOLUME ["/data/glusterfs", "/etc/glusterfs"]

ENV GLUSTER_VERSION 3.7

RUN curl -o /etc/yum.repos.d/glusterfs-fedora.repo \
    https://download.gluster.org/pub/gluster/glusterfs/${GLUSTER_VERSION}/LATEST/Fedora/glusterfs-fedora.repo \
 && rpmkeys --import https://download.gluster.org/pub/gluster/glusterfs/${GLUSTER_VERSION}/LATEST/Fedora/pub.key \
 && dnf --setopt=tsflags=nodocs -y install glusterfs-server \
 && dnf clean all \
 && mv /etc/glusterfs /etc/glusterfs.default

ADD install.sh uninstall.sh entrypoint.sh /bin/

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["daemon"]

LABEL INSTALL="docker run --rm --privileged --entrypoint /bin/sh -v /:/host -e HOST=/host -e LOGDIR=\${LOGDIR} -e CONFDIR=\${CONFDIR} -e DATADIR=\${DATADIR} -e IMAGE=IMAGE -e NAME=NAME IMAGE /bin/install.sh"
LABEL UNINSTALL="docker run --rm --privileged --entrypoint /bin/sh -v /:/host -e HOST=/host -e IMAGE=IMAGE -e NAME=NAME IMAGE /bin/uninstall.sh"
LABEL RUN="docker run --rm --privileged -p 24007-24008:24007-24008/tcp -p 49152-49161:49152-49161/tcp -v /var/data/glusterfs:/data/glusterfs -v /etc/glusterfs:/etc/glusterfs -n NAME IMAGE daemon"
