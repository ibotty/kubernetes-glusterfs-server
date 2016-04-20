chroot_host() {
    if [[ -v HOST ]]; then
        chroot $HOST $@
    else
        eval $@
    fi
}

test_var() {
    if [[ ! -v "$1" ]]; then
        err "Required variable $1 is not set."
        return 1
    fi
}

err() {
    echo "$@" >&2
}

mount_bricks() {
    chroot_host lvs -S pool_lv="${GLUSTER_POOL}" "${GLUSTER_VG}" --noheadings -o lv_name \
      | while read b; do
            echo "mounting $b"
            mkdir -p /bricks/"$b"
            mount "${HOST}/dev/${GLUSTER_VG}/${b}" "/bricks/$b"
        done
}

vg_exists() {
    chroot_host vgdisplay "$1" &> /dev/null
}

pool_exists() {
    chroot_host lvdisplay "$1" &> /dev/null
}
