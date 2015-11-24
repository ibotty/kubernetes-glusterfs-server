#!/bin/bash
set -e

err() {
    echo $* >&2
}

usage() {
    cat <<EOF
SYNOPSIS
       $0 [-p GLUSTER_POOL] [-v GLUSTER_VG]

Mount all volumes in the gluster thin pool GLUSTER_POOL in volume group 
GLUSTER_VG to /brick/BRICKNAME to be used by GlusterFS.
EOF
}

mount_bricks() {
    lvs -S pool_lv=${GLUSTER_POOL} ${GLUSTER_VG} --noheadings -o lv_name | \
        while read b; do
            echo "mounting $b"
            mkdir -p /bricks/$b
            mount /dev/${GLUSTER_VG}/${b} /bricks/$b
        done
}

main() {
  while getopts "p:v:u" flag
  do
    case "$flag" in
      p)
        if [ -z ${OPTARG} ]; then
          err "Missing argument GLUSTER_POOL for -p"
          exit 1
        fi
        GLUSTER_POOL=$OPTARG
        ;;
      v)
        if [ -z ${OPTARG} ]; then
          err "Missing argument GLUSTER_VG for -p"
          exit 1
        fi
        GLUSTER_VG=$OPTARG
        ;;
      u)
        usage
        exit 0
        ;;
      *)
        err "invalid option: $flag"
        exit 1
        ;;
    esac
  done
  mount_bricks
}

main
