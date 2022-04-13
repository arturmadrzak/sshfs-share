#!/bin/sh

set -eu

LOG_TAG=$(basename "${0}")

DEF_SSHD=/usr/sbin/sshd
DEF_PORT=60022
DEF_SSHD_CONF=/etc/ssh/sshd_config

e_err()
{
    echo "${LOG_TAG}: ERROR: ${*}" >&2
}

usage()
{
    echo "Usage: ${0} [OPTIONS] [--] [ARGS]"
    echo "Entrypoint for sshd service used for share resources via sshfs"
    echo "    -c|--sshd-conf  sshd config file (default:'${DEF_SSHD_CONF}')"
    echo "    -k|--key-path   host keys path (default:'${DEF_KEY_PATH}')"
    echo "    -p|--port       sshd listen port (default:'${DEF_PORT}')"
    echo "    -s|--sshd       sshd executable (default:'${DEF_SSHD}')"
    echo
}

main()
{
    if ! _temp=$(getopt \
        --options 'hc:p:s:' \
        --longoptions 'help,port:,sshd-conf:,sshd:' \
        --name "${0}" -- "$@");
        then
            usage
            exit 1
    fi

    # Note the quotes around "$TEMP": they are essential!
    eval set -- "${_temp}"
    unset _temp

    while true; do
        case "$1" in
            '-h'|'--help')
                usage
                exit 0
                ;;
            '-p'|'--port')
                _port=${2}
                shift 2
                continue
                ;;
            '-c'|'--sshd-conf')
                _sshd_conf=${2}
                shift 2
                continue
                ;;
            '-s'|'--sshd')
                _sshd=${2}
                shift 2
                continue
                ;;
            '--')
                shift
                break
                ;;
            *)
                echo 'Internal error!' >&2
                exit 1
                ;;
        esac
    done

    port=${_port:-${PORT:-${DEF_PORT}}}
    sshd_conf=${_sshd_conf:-${SSHD_CONF:-${DEF_SSHD_CONF}}}
    sshd=${_sshd:-${SSHD:-${DEF_SSHD}}}

    if [ ! -w "${sshd_conf}" ]; then
        e_err "No write permission for '${sshd_conf}'"
        exit 1
    fi
    sed -i \
        -e "s/#Port.*/Port ${port}/g" \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication yes/g' \
        -e 's/#PermitEmptyPasswords.*/PermitEmptyPasswords yes/g' \
        -e 's/#PermitRootLogin.*/PermitRootLogin yes/g' \
        "${sshd_conf}"

    ssh-keygen -A
    "${sshd}" -D
}

main "${@}"

exit 0
