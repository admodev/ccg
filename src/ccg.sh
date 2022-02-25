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

# Unique ID generator for commits:
uuid()
{
    local N B T

    for (( N=0; N < 16; ++N ))
    do
        B=$(( $RANDOM%255 ))

        if (( N == 6 ))
        then
            printf '4%x' $(( B%15 ))
        elif (( N == 8 ))
        then
            local C='89ab'
            printf '%c%x' ${C:$(( $RANDOM%${#C} )):1} $(( B%15 ))
        else
            printf '%02x' $B
        fi

        for T in 3 5 7 9
        do
            if (( T == N ))
            then
                printf '-'
                break
            fi
        done
    done

    echo
}

prompt_merge() {
    while true; do
        printf "Merge current branch into otherBranch (y/n) ? "
        read answer || return 1
        case "$answer" in
            [yY])
                return 0
                ;;
            [nN]*)
                return 1
                ;;
        esac
    done
}

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

    # TODO: look for repository and append commit to that repo tree.
    if [ $1 == "commit" ]
    then
        commit_id="$(uuid)"
        unix_timestamp=$(date +%s)
        timestamp=$(date +%T)
        read -p "Enter commit message: " commit_message
        echo "Created commit with id: $commit_id"
        echo "Commit message: $commit_message"
        echo "Created at: $timestamp"
    fi

    if [ $1 == "merge" ]
    then
        prompt_merge
    fi
fi
