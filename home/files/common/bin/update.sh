#!/bin/bash

# Update functions are dynamically collected using their name (update_*) and
# called indirectly to add cross-cutting functionality. The functions should
# return a proper error code. The functions are invoked in a "set -x" context
# and wrapped in logging/timing output. So echos can be used sparingly.

# shellcheck disable=SC2317 # Command appears to be unreachable
# shellcheck disable=SC2329 # This function is never invoked

update_locate() {
    # This might produce a lot of output from gfind because it cannot access parts of the filesystem (anymore, thank you Apple)
    sudo gupdatedb 2>/dev/null
}

update_appstore() {
    mas outdated
    mas upgrade
}

update_brew() {
    local local_rc=0

    export HOMEBREW_CURLRC=~/.curlrc
    #export HOMEBREW_CURL_RETRIES=2
    echo "Capturing installed package list"
    brew list --versions > "$(roll_file ~/backup/brew_packages.txt)"
    brew tap > "$(roll_file ~/backup/brew_taps.txt)"

    brew update && brew upgrade --yes
    (( local_rc += $? ))
    brew upgrade --cask --greedy --yes
    (( local_rc += $? ))
    brew cleanup
    (( local_rc += $? ))

    cache_dir="$(brew --cache)" || return 1
    find "${cache_dir}" -type l -mtime +14 | while read -r link; do
        target="$(readlink "${link}")"
        case "${target}" in
            /*) ;;
            *) target="$(dirname "${link}")/${target}" ;;
        esac
        rm -f -- "${link}" "${target}"
    done

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

    # python3.12 and later are protected system-level installs. Keep the discipline to only pip-install in venvs.
    for PYTHON_VERSION in 3.10 3.11 ; do
        echo "Updating python version ${PYTHON_VERSION}"
        echo "Capturing installed package list"
        "pip${PYTHON_VERSION}" list --format json | jq > "$(roll_file "${HOME}/backup/python${PYTHON_VERSION}_packages.json")"
        OUTDATED="$("pip${PYTHON_VERSION}" list -o --format json)"
        if [[ $(echo "${OUTDATED}" | jq length) == 0 ]] ; then
            echo "Everything up to date"
        else
            echo "${OUTDATED}" | jq -r .[].name | xargs "pip${PYTHON_VERSION}" install -U  ; ((local_rc += $?))
        fi
    done
    return "${local_rc}"
}

update_uv() {
    command -v uv
    for TOOL in ~/.local/share/uv/tools/* ; do
        uv tool upgrade "$(basename "${TOOL}")"
    done
}

update_helm() {
    command -v helm
    helm repo update
}

update_krew() {
    command -v krew
    krew upgrade
}

update_rust() {
    ~/.cargo/bin/rustup update
    ~/.cargo/bin/cargo install-update -a
}

update_ruby() {
    # It is crucial not to do "gem update --system". That will destroy the brew-installed system ruby!
    command -v gem
    # Do not use plain `gem update` because it will mess with brew cellar gems
    gem update --user-install
}

log() {
    echo "$(date +'%F %R:%S')" "${*}"
}

# Rolls $1 to older version if it exists, preserving three generations.
# Writes $1 to &1 so it can be chained by the caller
roll_file() {
    { set +x; } 2>/dev/null
    if [[ -f "${1}" ]] ; then
        for NUM in 2 1 ; do
            if [[ -f "${1}.${NUM}" ]] ; then
                mv "${1}.${NUM}" "${1}.$(( NUM + 1 ))"
            fi
        done
        mv "${1}" "${1}.1"
    fi
    echo "$1"
    set -x
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

# Invokes "update_${1}" and wraps it in logging and time measurement
invoke_update_func() {
    local_rc=0
    local timer=${SECONDS}
    log "Start updating ${1}"
    set -x
    "update_${1}" ; (( local_rc += $? ))
    { set +x; } 2>/dev/null
    log "Finished updating ${1} in $(( SECONDS - timer ))s, rc=${local_rc}"
    return ${local_rc}
}

close_firewall() {
    echo "Closing firewall"
    sudo littlesnitch rulegroup --disable update
}

# The global list of all implemented update functions
FUNC_NAMES=($(get_update_funcs)) || exit 1

# The main return-code. All update functions add to it
RC=0

case "$1" in
    -h|--help|"")
        echo "Update components of the local system."
        echo "Use arguments -a/--all to update everything or use one or more of \"${FUNC_NAMES[*]}\" to update just that specific component."
        exit 1
        ;;
    *)
        if [[ $1 == '-a' ]] || [[ $1 == '--all' ]] ; then
            COMPONENTS="${FUNC_NAMES[*]}"
        else
            COMPONENTS="$*"
        fi
        log "----- Starting update of $* -----"
        echo "PATH=${PATH}"
        echo "id: $(id)"
        echo "sudo -l:"
        sudo -l
        echo "Opening firewall"
        trap close_firewall exit
        sudo littlesnitch rulegroup --enable update || exit 1
        TIMER=${SECONDS}
        COMPONENT_COUNT=0
        for FUNC in ${COMPONENTS} ; do
            if func_exists "${FUNC}" ; then
                (( COMPONENT_COUNT += 1 ))
                invoke_update_func "${FUNC}"
                (( RC += $? ))
            else
                echo "Component \"${FUNC}\" does not exist. Choose one or more of these: ${FUNC_NAMES[*]}. Or use -h/--help for help." >&2
                (( RC += 1 ))
            fi
        done
        log "Finished update of $* in $(( SECONDS - TIMER ))s, rc=${RC}"
        ;;
esac

if (( COMPONENT_COUNT > 0 )) ; then
    if (( RC > 0 )) ; then
        echo "There were errors in some updates, sending notification."
        pushover.sh -t "update.sh" "Update problems (rc=${RC}). Please review /var/log/local.daemon.update.log (hint: "grep Finished /var/log/local.daemon.update.log") and rerun manually."
    fi
else
    echo "Nothing updated."
    RC=1
fi

exit "${RC}"
