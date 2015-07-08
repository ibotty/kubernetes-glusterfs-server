# GlusterFs for (bare metal) atomic hosts

# This is WIP and might or might not work for you!

[![Docker
Status](https://dockeri.co/image/ibotty/gluster-server)](https://registry.hub.docker.com/u/ibotty/gluster-server/)

Atomic hosts do not support traditional installation of additional software
with e.g. rpm. That privileged docker container is meant to be run on system
startup (via a systemd unit) and support serving GlusterFS volumes.

It uses GlusterFS 3.7 from the GlusterFS fedora repository.


