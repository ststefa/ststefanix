#!/bin/bash
# ATTENTION! Managed by Nix

# tail files recursively

while getopts "h" OPT; do
    case $OPT in
    h)
        cat <<EOF
Perform 'tail -f' recursively on all files
usage: $(basename $0) -h|dir[ dir]*"
where:
  -h: print help and exit
  dir: directory to scan
EOF
        exit $(true)
        ;;
    esac
done

shift $((OPTIND-1))

tail -n0 -f $(find $@ -type f ! -regex "\(.*gz\|.*[0123456789]\)")
