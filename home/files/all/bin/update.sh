#!/bin/bash

# Update functions are dynamically collected using their name (update_*) and
# called indirectly to add cross-cutting functionality. The functions should
# return a proper error code. The functions are invoked in a "set -x" context
# and wrapped in logging/timing output. So echos can be used sparingly.

# shellcheck disable=SC2317

update_locate() {
    # This might produce a lot of output from gfind because it cannot access parts of the filesystem (anymore, thank you Apple)
    sudo gupdatedb 2>/dev/null
}

update_brew() {
    local local_rc=0

    echo "Capturing installed package list"
    brew list --versions > $(roll_file ~/backup/brew_packages.txt)
    brew tap > $(roll_file ~/backup/brew_taps.txt)

    brew update && brew upgrade
    (( local_rc += $? ))
    brew upgrade --cask --greedy
    (( local_rc += $? ))
    brew cleanup
    (( local_rc += $? ))

    return "${local_rc}"
}

# I no longer use macports because if its root requirements
#update_macports() {
#    sudo port selfupdate && \
#    sudo port upgrade outdated && \
#    sudo port uninstall inactive
#}

update_python() {
    log python managed by nix, not updating ; return 0
    local local_rc=0

    #for PYTHON_VERSION in $(ls -d /opt/homebrew/Cellar/python@* | sed -n 's/.*@\(.*\)/\1/p' | sort -V) ; do
    # python3.12 is now a protected system-level install. Keep the discipline to only pip-install in venvs.
    for PYTHON_VERSION in 3.10 3.11 ; do
        echo "Updating python version ${PYTHON_VERSION}"
        echo "Capturing installed package list"
        "pip${PYTHON_VERSION}" list --format json | jq > $(roll_file "${HOME}/backup/python${PYTHON_VERSION}_packages.json")
        OUTDATED="$("pip${PYTHON_VERSION}" list -o --format json)"
        if [[ $(echo "${OUTDATED}" | jq length) == 0 ]] ; then
            echo "Everything up to date"
        else
            echo "${OUTDATED}" | jq -r .[].name | xargs "pip${PYTHON_VERSION}" install -U  ; ((local_rc += $?))
        fi
    done
    return "${local_rc}"
}

update_pipx() {
    pipx upgrade-all
}

update_helm() {
    helm repo update
}

update_rust() {
    ~/.cargo/bin/rustup update
}

update_appstore() {
    mas outdated
    mas upgrade
}

log() {
    echo "$(date +'%F %R:%S')" "${*}"
}

# Rolls $1 to older version if it exists, preserving three generations.
# Writes $1 to &1 so it can be chained by the caller
roll_file() {
    if [[ -f "${1}" ]] ; then
        for NUM in 2 1 ; do
            if [[ -f "${1}.${NUM}" ]] ; then
                mv "${1}.${NUM}" "${1}.$(( NUM + 1 ))"
            fi
        done
        mv "${1}" "${1}.1"
    fi
    echo "$1"
}

# Dynamically collect list of update functions, identified by regex.
# The "update_" prefix is striped
get_update_funcs() {
    set | grep '^update_.*()' | sed 's/^update_\([^ ]*\) .*$/\1/' | sort
}

func_exists() {
    for F in "${FUNC_NAMES[@]}" ; do
        if [[ "${F}" == "${1}" ]] ; then
            return 0
        fi
    done
    return 1
}

# Invokes $1 in a verbose "set -x" context
invoke_func() {
    local local_rc=0
    set -x
    "${1}" ; (( local_rc += $? ))
    { set +x; } 2>/dev/null
    return ${local_rc}
}

# Invokes $1 and wraps it in logging and time measurement
invoke_update_func() {
    local local_rc=0
    local timer=${SECONDS}
    log "Start updating ${1}"
    invoke_func "update_${1}"
    (( local_rc += $? ))
    log "Finished updating ${1} in $(( SECONDS - timer ))s, rc=${local_rc}"
    return ${local_rc}
}

# The global list of all implemented update functions
FUNC_NAMES=($(get_update_funcs)) || exit 1

# The main return-code. All update functions add to it
RC=0

case "$1" in
    -h|--help|"")
        echo "Update components of the local system."
        echo "Use arguments -a/--all to update everything or use one of \"${FUNC_NAMES[*]}\" to update just that specific component."
        exit 1
        ;;
    -a|--all)
        log "----- Starting full system update -----"
        echo "PATH=${PATH}"
        TIMER=${SECONDS}
        for FUNC in "${FUNC_NAMES[@]}" ; do
            invoke_update_func "${FUNC}"
            (( RC += $? ))
        done
        log "Finished full system update in $(( SECONDS - TIMER ))s, rc=${RC}"
        ;;
    *)
        if func_exists "${1}" ; then
            invoke_update_func "${1}"
            (( RC += $? ))
        else
            echo "Component \"${1}\" does not exist. Choose one of these: ${FUNC_NAMES[*]}. Or use -h/--help for help." >&2
            exit 1
        fi
        ;;
esac

if (( RC > 0 )) ; then
    echo "There were errors, sending notification."
    pushover.sh -t "update.sh" "Update problems (rc=${RC}). Please review /var/log/local.daemon.update.log (hint: "grep Finished /var/log/local.daemon.update.log") and rerun manually."
fi

exit ${RC}
