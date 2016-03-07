# GlusterFs running inside a kubernetes cluster

# This is WIP and might or might not work for you!

[![Docker
Status](https://dockeri.co/image/ibotty/atomic-gluster-server)](https://registry.hub.docker.com/u/ibotty/atomic-gluster-server/)


## Known Bugs

### Cannot provision LVM volumes

Because systemd can't be run with `hostIPC` and LVM seems to need it.
