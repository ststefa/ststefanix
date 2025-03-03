#!/bin/bash
# ATTENTION! File managed by Puppet. Changes will be overwritten.

# tail files recursively

while getopts "h" OPT; do
    case $OPT in
    h)
        echo "Perform 'tail -f' recursively on all files" >&2
        echo "usage: $(basename $0) -h|dir[ dir]*"  >&2
        echo "where:"
        echo "  -h: print help and exit" >&2
        echo "  dir: directory to scan" >&2
        exit $(true)
        ;;
    esac
done

shift $((OPTIND-1))

tail -n0 -f $(find $@ -type f ! -regex "\(.*gz\|.*[0123456789]\)")
