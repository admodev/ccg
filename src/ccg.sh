#!/bin/bash

usage() {
    cat <<EOF

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

# Output color.
green=`tput setaf 2`
reset=`tput sgr0`

printf "${green}Welcome to CleanCodersGIT!${reset}\n"

if [ $# -eq 0 ]
then
    usage
fi

# Same arg check as above but check if arg is empty str.
# if [ -z "$1" ]
# then
#     echo "No argument supplied, if you need help, pass the --help flag."
# fi

# Initialize .git directory in current folder
if [ $1 == "init" ]
then
    mkdir .git
fi
