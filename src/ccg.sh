#!/bin/bash

# Output color.
green=`tput setaf 2`
reset=`tput sgr0`

usage() {
    cat <<EOF

${green}Welcome to CleanCodersGIT!${reset}

Usage: $0 [options] [--] [file...]

Arguments:

  -h, --help
    Display this usage message and exit.

  -h <command>, --help <command>
    Shows useful information about the given command.

EOF
}

# Error handling helper functions.
log() { printf '%s\n' "$*"; }
error() { log "ERROR: $*" >&2; }
fatal() { error "$*"; exit 1; }
usage_fatal() { error "$*"; usage >&2; exit 1; }

if [ $# -eq 0 ]
then
    usage
else
    # Initialize .git directory in current folder
    if [ $1 == "init" ]
    then
        mkdir -p -m 777 .git
        declare -a references=("objects" "refs" "refs/heads")
        for name in "${references[@]}"
        do
            mkdir .git/${name}
        done
        echo "ref: refs/heads/master" > .git/HEAD
        echo "initialized empty repository."
    fi
    
    # TODO: modify this method to show current status in VC of files and folders
    if [ $1 == "status" ]
    then
        ls
    fi
fi
