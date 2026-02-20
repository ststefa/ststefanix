#!/bin/bash
# Create ssh "tunnel over tunnel" setup local > JUMP_HOST > TUNNEL_HOST with
# ssh dynamic (-D) forwarding ports which can be used as SOCKS proxies.
# Both tunnels will be automatically re-established upon connection failures.


# Host to use for tunneling local > adminlan
#JUMP_HOST=viairz0175.t-systems.ch
JUMP_HOST=uvairz0120.t-systems.ch
# ssh socks proxy port to reach adminlan
JUMP_PORT=8081

# Host to use for tunneling local > sbb-lan over jump-host tunnel
#TUNNEL_HOST=wasi85a1e1.sbb.ch
TUNNEL_HOST=wast85a1e1.sbb.ch
# ssh socks proxy port to reach sbb-lan
TUNNEL_PORT=8082

# How many times to retry a failed connection
# Account on uvairz0120.t-systems.ch locks after 7 auth failures!
MAX_RETRIES=5

# How long to wait between connection attempts
RETRY_DELAY=3


case "$(uname -s)" in
    Darwin)
        if [ -x '/opt/local/libexec/gnubin/readlink' ] ; then
            # use linux-like command from macports installation
            MY_DIR="$(dirname "$(/opt/local/libexec/gnubin/readlink -nf "${0}")")" || exit 1
        else
            # use mac-os vintage command (not symlink-aware!)
            MY_DIR="$(dirname "${0}")" || exit 1
        fi
        ;;
    *)
        MY_DIR="$(dirname "$(readlink -nf "${0}")")" || exit 1
        ;;
esac

# determine age of file and prettyprint it as hms
get_file_age () {
    FILENAME="${1}"
    local AGE_SECONDS
    case $(uname -s) in
        # see https://unix.stackexchange.com/questions/102691/get-age-of-given-file
        Darwin)
            if [ -x '/opt/local/libexec/gnubin/date' ] ; then
                # use linux-like command from macports installation
                AGE_SECONDS=$(($(/opt/local/libexec/gnubin/date +%s) - $(/opt/local/libexec/gnubin/date +%s -r "${FILENAME}"))) || return 1
            else
                # use mac-os vintage command
                AGE_SECONDS=$(( $(date +%s) - $(stat -t %s -f %m -- "${FILENAME}") )) || return 1
            fi
            ;;
        *)
            AGE_SECONDS=$(($(date +%s) - $(date +%s -r "${FILENAME}"))) || return 1
            ;;
    esac
    if (( AGE_SECONDS > 3600 )) ; then
        # e.g. "3h55m0s"
        echo $(( AGE_SECONDS / 3600 % 60 ))h$(( AGE_SECONDS / 60 % 60 ))m$(( AGE_SECONDS % 60 ))s
    elif (( AGE_SECONDS > 60 )) ; then
        # e.g. "2m53s"
        echo $(( AGE_SECONDS / 60 ))m$(( AGE_SECONDS % 60 ))s
    else
        # e.g. "34s"
        echo ${AGE_SECONDS}s
    fi
}

# used for echoing from background processes
log () {
    echo "$(date +"%Y-%m-%d %H:%m:%S") $(basename "${0}") $$: ${*}"
}

connect () {
    local TGT_HOST="${1}"
    local TUN_PORT="${2}"
    if [ -f "${MY_DIR}/${TGT_HOST}.PID" ] ; then
        PID="$(cat "${MY_DIR}/${TGT_HOST}.PID")"
        if ps -p "${PID}" > /dev/null; then
            log "Connector to ${TGT_HOST} already running (PID ${PID})"
            return 1
        else
            log "Removing dead pidfile for ${TGT_HOST}"
        fi
    fi
    local ATTEMPT=0
    local COUNT=0
    while ! [ -f "${MY_DIR}/tsstunnel.TERM" ] ; do
        (( ATTEMPT++ ))
        if (( ATTEMPT > 1 )) ; then
            log "Throttling ${TGT_HOST} connector for ${RETRY_DELAY}s"
            sleep "${RETRY_DELAY}"
        fi
        if (( ATTEMPT > MAX_RETRIES )) ; then
            log "${TGT_HOST} connector bailing out"
            break
        fi
        SSH_SOCK_FILE="${MY_DIR}/${TGT_HOST}.sshsock"
        PID_FILE="${MY_DIR}/${TGT_HOST}.PID"
        log "Connecting to $TGT_HOST exposing proxy on port ${TUN_PORT} (attempt ${ATTEMPT}/${MAX_RETRIES})"
        ssh -D"${TUN_PORT}" -N -o PasswordAuthentication=no -o ConnectTimeout=5 -o ServerAliveInterval=10 -o ControlMaster=yes -o ControlPath="${SSH_SOCK_FILE}" "${TGT_HOST}" 2>&1 &
        PID=$!
        SECONDS=0
        while [ ! -S "${SSH_SOCK_FILE}" ] && ps -p "${PID}" > /dev/null ; do
            (( COUNT++ ))
            sleep 0.1
            if (( $(( COUNT % 10 )) == 0 )) ; then
                log "waiting for ${TGT_HOST} socket file since ${SECONDS}s ..."
            fi
        done
        if ! ps -p "${PID}" > /dev/null ; then
            log "ssh connection to ${TGT_HOST} failed"
        else
            echo ${PID} > "${PID_FILE}"
            wait ${PID} #...and check that TUN_PORT is alive?
            WAIT_RC=${?}
            RUNTIME=$(get_file_age "${PID_FILE}")
            log "${TGT_HOST} connector (PID ${PID}) exited after ${RUNTIME} with rc ${WAIT_RC}"
            rm "${PID_FILE}"
        fi
    done
    log "Connector to ${TGT_HOST} exited"
}

wait_for_pidfile () {
    local TGT_HOST="${1}"
    local COUNT=0

    SECONDS=0
    # wait time must be longer than longest time for ssh connect attempt
    while [ ! -f "${MY_DIR}/${TGT_HOST}.PID" ]  && (( SECONDS < 15 )) ; do
        (( COUNT++ ))
        sleep 0.1
        if (( $(( COUNT % 50 )) == 0 )) ; then
            log "waiting for ${TGT_HOST} pidfile since ${SECONDS}s ..."
        fi
    done
    [ -f "${MY_DIR}/${TGT_HOST}.PID" ]
    return $?
}

disconnect () {
    local TGT_HOST"=${1}"
    local COUNT=0
    if [ -f "${MY_DIR}/${TGT_HOST}.PID" ] ; then
        local PID
        PID="$(cat "${MY_DIR}/${TGT_HOST}.PID")"
        if ! ps -p "${PID}" > /dev/null; then
            log "Connector for ${TGT_HOST} (PID ${PID}) dead"
        else
            log "Disconnecting ${TGT_HOST} by killing ${PID}"
            kill "${PID}"
            SECONDS=0
            while ps -p "${PID}" > /dev/null && (( SECONDS < 5 )) ; do
                (( COUNT++ ))
                sleep 0.1
                if (( $(( COUNT % 10 )) == 0 )) ; then
                    log "waiting for ${TGT_HOST} PID ${PID} since ${SECONDS}s ..."
                fi
            done
            if ps -p "${PID}" > /dev/null; then
                log "${TGT_HOST} PID ${PID} refuses to die, sending SIGKILL"
                kill -9 "${PID}"
                SECONDS=0
                while ps -p "${PID}" > /dev/null && (( SECONDS < 5 )) ; do
                    (( COUNT++ ))
                    sleep 0.1
                    if (( $(( COUNT % 10 )) == 0 )) ; then
                        log "waiting for ${TGT_HOST} PID ${PID} since ${SECONDS}s ..."
                    fi
                done
            fi
            if ps -p "${PID}" > /dev/null; then
                log "Unable to terminate ${TGT_HOST} PID ${PID}"
                return 1
            fi
        fi
    else
        log "Connector for ${TGT_HOST} not running"
    fi
}

status () {
    local TGT_HOST="${1}"
    if [ -f "${MY_DIR}/${TGT_HOST}.PID" ] ; then
        PID="$(cat "${MY_DIR}/${TGT_HOST}.PID")"
        RUNTIME=$(get_file_age "${MY_DIR}/${TGT_HOST}.PID")
        if ps -p "${PID}" > /dev/null ; then
            echo "Connector to ${TGT_HOST} running since ${RUNTIME} (PID ${PID})"
        else
            echo "Connector to ${TGT_HOST} dead but pidfile ${MY_DIR}/${TGT_HOST}.PID still present"
            return 1
        fi
    else
        echo "Connector to ${TGT_HOST} stopped"
    fi
}

RC=0
case ${1} in
    start)
        if  [ -f "${MY_DIR}/tsstunnel.TERM" ] ; then
            echo "$(basename "${0}") shutting down, cannot start"
            exit 1
        else
            connect ${JUMP_HOST} ${JUMP_PORT} &
            wait_for_pidfile ${JUMP_HOST}
            (( RC += ${?} ))
            if (( RC != 0 )) ; then
                echo "tunnel to ${JUMP_HOST} failed, not attempting tunnel to ${TUNNEL_HOST}"
            else
                connect ${TUNNEL_HOST} ${TUNNEL_PORT} &
                wait_for_pidfile ${TUNNEL_HOST}
                (( RC += ${?} ))
            fi
        fi
        ;;
    stop)
        touch "${MY_DIR}/tsstunnel.TERM"
        disconnect ${TUNNEL_HOST}
        (( RC += ${?} ))
        disconnect ${JUMP_HOST}
        (( RC += ${?} ))
        while [ -f "${MY_DIR}/${JUMP_HOST}.PID" ]  || [ -f "${MY_DIR}/${TUNNEL_HOST}.PID" ] ; do
            (( COUNT++ ))
            sleep 0.1
            if (( $(( COUNT % 50 )) == 0 )) ; then
                log "ssh processes do not do away. Open another session and kill them manually"
            fi
        done
        rm "${MY_DIR}/tsstunnel.TERM"
        ;;
    status)
        if  [ -f "${MY_DIR}/tsstunnel.TERM" ] ; then
            echo "currently shutting down"
        fi
        status "${JUMP_HOST}"
        (( RC += ${?} ))
        status "${TUNNEL_HOST}"
        (( RC += ${?} ))
        ;;
    *)
        echo "usage: $(basename "${0}") (start|stop|status)" >&2
        false
        ;;
esac

exit "${RC}"
