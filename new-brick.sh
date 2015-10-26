#!/bin/sh

set -e

GLUSTER_VG=${GLUSTER_VG-fedora}
GLUSTER_POOL=${BRICK_NAME-'gluster-pool'}
BRICK_NAME=${BRICK_NAME-''}

mk_brick() {
    lvcreate -TV 1G -n $BRICK_NAME $GLUSTER_VG/$GLUSTER_POOL
    mkfs.xfs /dev/$GLUSTER_VG/$BRICK_NAME -L $BRICK_NAME
    mount -t xfs /dev/$GLUSTER_VG/$BRICK_NAME $BRICK_NAME
}

mount_brick() {
    mkdir /$BRICK_NAME
    mount /dev/$GLUSTER_VG/$BRICK_NAME /$BRICK_NAME
}

usage() {
    cat <<EOF 
$0 [-v GLUSTER_VG] [-p GLUSTER_POOL] [BRICK_NAME]
where 
 * GLUSTER_VG is the volume group to use,
 * GLUSTER_POOL is the thin pool to use, and
 * BRICK_NAME is the brick name to use.
All options can be specified by environment variables.
GLUSTER_VG defaults to fedora, GLUSTER_POOL to gluster-pool.
EOF
}

main() {
    while getopts "v:p:" flag
    do
        case "$flag" in
        v)
            if [ -z ${OPTARG} ]; then
                err "Missing argument GLUSTER_VG for -v"
                exit 1
            fi
            GLUSTER_VG=$OPTARG
            ;;
        p)
            if [ -z ${OPTARG} ]; then
                err "Missing argument GLUSTER_POOL for -p"
                exit 1
            fi
            GLUSTER_POOL=$OPTARG
            ;;
        *)
            err "invalid option: $flag"
            usage
            exit 1
        esac
    done
    shift $(( OPTIND - 1 ));

    if [ $# -eq 1 ] ; then
        BRICK_NAME=$1
    fi

    if [ -z $BRICK_NAME ]; then
        err "Missing argument or environment variable BRICK_NAME"
        exit 1
    fi
}

main
