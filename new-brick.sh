#!/bin/sh

set -e

GLUSTER_VG=${GLUSTER_VG-fedora}
GLUSTER_POOL=${BRICK_NAME-'gluster-pool'}
BRICK_NAME=${BRICK_NAME-''}
BRICK_SIZE=${BRICK_SIZE-10GiB}

mk_brick() {
    lvcreate -TV $BRICK_SIZE -n $BRICK_NAME $GLUSTER_VG/$GLUSTER_POOL
    mkfs.xfs /dev/$GLUSTER_VG/$BRICK_NAME -L $BRICK_NAME
}

mount_brick() {
    mkdir /bricks/$BRICK_NAME
    mount -t xfs /dev/$GLUSTER_VG/$BRICK_NAME /bricks/$BRICK_NAME
}

usage() {
    cat <<EOF 
$0 [-v GLUSTER_VG] [-p GLUSTER_POOL] [-s BRICK_SIZE] [BRICK_NAME]
where 
 * GLUSTER_VG is the volume group to use,
 * GLUSTER_POOL is the thin pool to use,
 * BRICK_SIZE is the size of the brick as excepted by lvcreate(5), and
 * BRICK_NAME is the brick name to use.
All options can be specified by environment variables.
GLUSTER_VG defaults to fedora, GLUSTER_POOL to gluster-pool,
BRICK_SIZE to 10GiB.
EOF
}

main() {
    while getopts "v:p:s:" flag
    do
        case "$flag" in
        v)
            if [ -z ${OPTARG} ]; then
                err "Missing argument GLUSTER_VG for -v"
                exit 1
            fi
            GLUSTER_VG=$OPTARG
            ;;
        s)
            if [ -z ${OPTARG} ]; then
                err "Missing argument BRICK_SIZE for -s"
                exit 1
            fi
            BRICK_SIZE=$OPTARG
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
