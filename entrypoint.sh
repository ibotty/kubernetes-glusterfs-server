#!/bin/bash
# Entrypoint for glusterfs-server

set -e

GLUSTERD_OPTIONS="-N --log-file=/dev/stdout"

USAGE="SYNOPSIS
       atomic run --spc -n ${NAME} ${IMAGE} COMMAND [arg...]

COMMANDS
       daemon [-L <LOGLEVEL>]
         Start glusterd(8) in foreground. LOGLEVEL is the log severity. 
         See glusterd(8) for details.

       glusterfs [args]
         Run glusterfs(8) with the specified args.

       bash | sh | /bin/bash | /bin/sh
         Run a shell in the container.

       usage
         Show this usage information.
"

err() {
  echo $* >&2
}

mount_bricks() {
    BRICKS=$(lvs -S pool_lv=${GLUSTER_POOL} ${GLUSTER_VG} --noheadings -o lv_name)
    for b in $BRICKS; do
        mkdir /$b
        mount /dev/${GLUSTER_VG}/${b} /$b
    done
}

daemon() {
  while getopts "L:" flag
  do
    case "$flag" in
      L)
        if [ -z ${OPTARG} ]; then
          err "Missing argument LOGLEVEL for -L"
          exit 1
        fi
        GLUSTERD_OPTIONS="$GLUSTERD_OPTIONS -L $OPTARG"
        ;;
      *)
        err "invalid option: $flag"
        exit 1
    esac
  done
  exec /sbin/glusterd $GLUSTERD_OPTIONS
}

cmd="$1"
shift
case "$cmd" in
    daemon)
      daemon $@
      ;;
    glusterfs)
      exec /sbin/glusterfs "$@"
      ;;
    bash|/bin/bash|sh|/bin/sh)
      exec /bin/bash "$@"
      ;;
    usage|*)
      echo "$USAGE"
      ;;
esac
