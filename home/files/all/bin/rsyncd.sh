#!/bin/bash
# $Id: ssteine2 $
# Call rsync whenever a change is detected. Prevent multiple
# parallel executions.
set -x
MY_DIR="$(dirname "$0")"

t_echo () {
    echo "$(date +%T) $*"
}

end_sync() {
    LOOP=false
}

terminate() {
    if (( $(cat "${MY_DIR}/sync.lock") == $$ )) ; then
        echo "removing lockfile ${MY_DIR}/sync.lock"
        rm "${MY_DIR}/sync.lock"
    fi
}

if [[ $1 == "-h" ]] ||  [[ $1 == "--help" ]]; then
    echo "Synchronize source to dest forever upon any file change (until interrupted with Ctrl-C)"
    echo "usage: $(basename $0) source [host:]/dest/path"
    exit 1
fi

if (( $# != 2 )) ; then
    echo "Need source and dest" >&2
    exit 1
fi

SOURCE="${1}"
TARGET="${2}"

if [[ -a "${MY_DIR}/sync.lock" ]] ; then
    PID=$(cat "${MY_DIR}/sync.lock")
    if ps -p "${PID}" > /dev/null 2>&1 ; then
        echo "$0 already running (PID ${PID})" >&2
        exit 1
    else
        echo "Removing ${MY_DIR}/sync.lock for dead PID ${PID}"
        rm "${MY_DIR}/sync.lock"
    fi
fi
echo $$ > "${MY_DIR}/sync.lock"

# Cleanup on exit
trap terminate exit

# Exit endless loop on Ctrl-C
trap end_sync SIGINT

t_echo "Initial rsync starting"
set -x
rsync -a --verbose "${SOURCE}" "${TARGET}" || exit 1
set +x
t_echo "Initial rsync complete"

LOOP=true
while $LOOP ; do
    t_echo "waiting for changes (ctrl-c to end)..."
    fswatch -1 -r "${SOURCE}" > /dev/null
    if ${LOOP}; then
        t_echo "rsync starting"
        set -x
        rsync -a --verbose "${SOURCE}" "${TARGET}" || exit 1
        set +x
        t_echo "rsync complete"
    fi
done
