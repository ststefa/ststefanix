# Functions used for shell prompt

parse_git_branch() {
    local BRANCH
    BRANCH="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
    if (( ${#BRANCH} > 8 )) ; then
        BRANCH="${BRANCH:0:3}..${BRANCH: -3}"
    fi
    echo "${BRANCH}"
}

parse_cwd() {
    if [[ $(pwd) == "${HOME}" ]] ; then
        CWD="~"
    else
        local CWD
        CWD="$(basename "$(pwd)")"
        if (( ${#CWD} > 12 )) ; then
            CWD="${CWD:0:5}..${CWD: -5}"
        fi
    fi
    echo "${CWD}"
}

# Using separate config files instead of contexts
parse_k8s_ctx() {
    local CONTEXT
    CONTEXT="$(kc)"
    if (( ${#CONTEXT} > 6 )) ; then
        CONTEXT="${CONTEXT:0:2}..${CONTEXT: -2}"
    fi
    echo "${CONTEXT}"
}

# Dump plist file as json
plview() {
    for FILE in $@ ; do
        plutil -convert json "${FILE}" -o - | jq
    done
}

# Simulate Linux ss only if no native `ss` command exists
if ! command -v ss >/dev/null 2>&1; then
    ss() {
        tcp_flag=false
        udp_flag=false
        listen_flag=false
        numeric_flag=false
        # No getopt on vanilla MacOS :-(. Do it by hand.
        for arg in "$@"; do
            if [[ "${arg}" == -* ]]; then
                chars="${arg#-}"
                for (( i=0; i<${#chars}; i++ )); do
                    c="${chars:$i:1}"
                    case "${c}" in
                    t) tcp_flag=true ;;
                    u) udp_flag=true ;;
                    l) listen_flag=true ;;
                    p) ;;  # for compat, processes always show with lsof
                    e) ;;  # for compat, ignore
                    n) numeric_flag=true ;;
                    h)
                        echo "Simulate the Linux ss command (which displays network sockets) using lsof." >&2
                        echo "usage: ss -(t,u,l,p,e,n)" >&2
                        echo "where:" >&2
                        echo "t: Show TCP sockets (default)" >&2
                        echo "u: Show UDP sockets" >&2
                        echo "l: Show only listening sockets" >&2
                        echo "p: Show process using socket (always on, ignored)" >&2
                        echo "e: Show detailed socket information (always on, ignored)" >&2
                        echo "n: Do not resolve service names (faster)" >&2
                        return
                        ;;
                    *) echo "Unsupported option: -${c}, try -h" >&2; return 1 ;;
                    esac
                done
            else
                echo "Unsupported argument: ${arg}" >&2
                return 1
            fi
        done
        if ! ${tcp_flag} && ! ${udp_flag}; then
            tcp_flag=true
        fi
        lsof_flags=""
        ${numeric_flag} && lsof_flags="${lsof_flags} -nP"
        ${tcp_flag} && lsof_flags="${lsof_flags} -iTCP"
        ${tcp_flag} && ${listen_flag} && lsof_flags="${lsof_flags} -sTCP:LISTEN"
        ${udp_flag} && lsof_flags="${lsof_flags} -iUDP"
        lsof ${lsof_flags}
    }
    export -f ss
fi

# Export functions to child processes. Make sure to capture all funcs from above
export -f parse_git_branch parse_cwd parse_k8s_ctx plview
