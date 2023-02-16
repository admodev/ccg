#!/bin/bash

# Output color.
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
white=$(tput setaf 7)
reset=$(tput sgr0)

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
fatal() {
    error "$*"
    exit 1
}
usage_fatal() {
    error "$*"
    usage >&2
    exit 1
}

# Unique ID generator for commits:
uuid() {
    local N B T

    for ((N = 0; N < 16; ++N)); do
        B=$(($RANDOM % 255))

        if ((N == 6)); then
            printf '4%x' $((B % 15))
        elif ((N == 8)); then
            local C='89ab'
            printf '%c%x' ${C:$(($RANDOM % ${#C})):1} $((B % 15))
        else
            printf '%02x' $B
        fi

        for T in 3 5 7 9; do
            if ((T == N)); then
                printf '-'
                break
            fi
        done
    done

    echo
}

prompt_merge() {
    while true
    do
        DESTINATION_BRANCH=$1
        CURRENT_BRANCH=""

        if [[ ! $DESTINATION_BRANCH ]]; then
            echo ${red}"You need to specify the version control system and the branch you want to merge."${reset}
            exit 1
        fi

        printf "Select which version control you are currently using: (g)it, (s)ubversion. "
        read ans || return 1
        case "$ans" in
            [gitGIT]*)
                echo "Using GIT"
                CURRENT_BRANCH=`git branch | awk '{ print $2 }'`

                printf "Merge branch ${green}${DESTINATION_BRANCH}${reset} into ${CURRENT_BRANCH} (y/n) ? "

                read answer || return 1
                case "$answer" in
                    [yY]*)
                        printf "Merging $DESTINATION_BRANCH into: $CURRENT_BRANCH\n"

                        git merge $DESTINATION_BRANCH
                        git push origin $CURRENT_BRANCH

                        echo "Branch merging finished successfully!"

                        return 0
                        ;;
                    [nN]*)
                        exit 1
                        ;;
                esac
                return 0
                ;;
        esac
    done
}

# Initialize .git directory in current folder
init() {
    mkdir -p -m 777 .git
    declare -a references=("objects" "refs" "refs/heads")
    for name in "${references[@]}"; do
        mkdir .git/${name}
    done

    touch .git/.repos
    repository=([0]=0)

    printf "%s\n" "${repository[@]}" > .git/.repos
    echo "ref: refs/heads/master" >.git/HEAD
    echo "initialized empty repository."
}

# This function makes a .ssh directory with identiy file for different providers (GitHub, Gitlab, e.t.c.)
# Params: #1 = provider #2 = your@email.com #3 = your_username
# Is it viable to change the order of parameters, to for example: #1 email #2 username #3 provider?
set_identity() {
    dir=$HOME/.ssh
    provider=''
    email=''
    username=''

    while getopts 'p:e:u:' flag; do
        case "${flag}" in
        p) provider="${OPTARG} ;;
        e) email="${OPTARG} ;;
        u) username="${OPTARG}" ;;
        *)
            usage
            exit 1
            ;;
        esac
    done

    if [ ! -d $dir ]; then
        mkdir $dir
    fi

    yes | ssh-keygen -t ed25519 -C $email -f "${HOME}/.ssh/${username}_${provider}"
    
    if [ ! -f $HOME/.ssh/config ]; then
        cat > $HOME/.ssh/config <<- EOM
        Host $1
        User $username
        IdentityFile $HOME/.ssh/${username}_${provider}
        IdentitiesOnly yes
EOM
    else
        # NOTE: tee command only works on unix.
        tee -a $HOME/.ssh/config <<EOM
        Host $1
        User $username
        IdentityFile $HOME/.ssh/${username}_${provider}
        IdentitiesOnly yes
EOM
    fi
}

status() {
    while true
    do
        printf "Select which version control you are currently using: (g)it, (s)ubversion. "
        read ans || return 1
        case "$ans" in
            [gitGIT]*)
                echo "Using GIT"

                git status

                return 0
                ;;
            *)
                printf "${red}Please, select at least one version control system...${reset}"

                exit 1
                ;;
        esac
    done
}

search_repo() {
    cat .git/.repos
    return 0
}

# TODO: look for repository and append commit to that repo tree.
commit() {
    commit_id="$(uuid)"
    unix_timestamp=$(date +%s)
    timestamp=$(date +%T)
    read -p "Enter commit message: " commit_message

    if [[ ! $commit_message ]]; then
        echo "Please, enter a commit message..."
        exit 1
    fi

    echo "Created commit with id: $commit_id"
    echo "Commit message: $commit_message"
    echo "Created at: $timestamp"
}

for ARG in ${@}; do
    case "$ARG" in
    "identity")
        set_identity
        ;;
    "init")
        init
        ;;
    "status")
        status
        ;;
    "commit")
        commit
        ;;
    "merge")
        prompt_merge $2
        ;;
    # TODO!: apply usage when wrong args are passed
    # *)
    #    usage
    #    ;;
    esac
done

if [ $# -eq 0 ]; then
    usage
fi
