#!/bin/bash
# The default limit for number of files in a .git directory

# shellcheck disable=SC2312

LIMIT=100
CHECK=false

while getopts "cl:h" OPT; do
    case $OPT in
    l)
        LIMIT="${OPTARG}"
        ;;
    c)
        CHECK=true
        ;;
    h)
        echo "Recursively traverse one or more directory trees and perform garbage collection on certain git repositories found therein."
        echo "Prints a list of <dirname>:<num_files> to stdout where <dirname> is the git repository and <num_files> is the number of files in its .git directory (potentially after compaction)."
        echo "Usage: $(basename $0) [-c] [-l <limit>] <dirname>[ <dirname>]* | -h"
        echo "where"
        echo "-c          Just check and report, do not perform gc"
        echo "-l <limit>  Garbage-collect only repos whose .git dir exceeds <limit> files, default ${LIMIT}"
        echo "<dirname>   A directory base to descend into"
        exit 1
        ;;
    *)
        echo "$0: illegal option ${OPTARG}" >&2
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
    while read -r REPO_DIR ; do
        NUM_FILES=$(du -s --inodes "${REPO_DIR}" | cut -f1)
        if (( NUM_FILES > LIMIT )) ; then
            if ! ${CHECK} ; then
                git -C "${REPO_DIR}" gc --quiet
            fi
            echo "${REPO_DIR}:$(du -s --inodes "${REPO_DIR}" | cut -f1)"
        fi
    done < <(find "${BASE_DIR}" -type d -name .git)
done
