#!/bin/bash
# Recursively pull git repos

while getopts "cl:h" OPT; do
    case $OPT in
    l)
        LIMIT="${OPTARG}"
        ;;
    c)
        CHECK=true
        ;;
    h)
        cat <<EOF
Recursively traverse one or more directory trees and pull git repositories found therein.
Usage: $(basename $0) <dirname>[ <dirname>]* | -h
where
<dirname>   A directory base to descend into
-h          Print help and exit
EOF
        ;;
    *)
        echo "$0: illegal option ${OPTARG}, try '-h'" >&2
        exit 1
        ;;
    esac
done

shift $(( OPTIND - 1 ))
BASE_DIRS=("$@")

if (( ${#BASE_DIRS[@]} == 0 )); then
    echo "One or more base directories must be specified. See -h for usage."
    exit 1
fi

for BASE_DIR in "${BASE_DIRS[@]}" ; do
    find ${BASE_DIR} -type d -name .git -print0 | xargs -0 -I_ -P$(getconf _NPROCESSORS_ONLN) -n1 bash -c "cd _ || exit 1; cd ..; git pull"
done
