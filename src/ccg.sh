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

Commands:
  identity -p <provider> -e <email> -u <username>  Sets up an SSH identity for the given provider.
  init                                             Initializes an empty Git repository.
  status                                           Shows the status of the current repository.
  commit                                           Creates a new commit with a unique ID and a commit message.
  merge <destination-branch>                       Merges the specified branch into the current branch.
  push                                             Pushes the current branch to the remote repository.
  check <file>                                     Displays the contents of the specified file.
  fp                                               Fetches all branches and pulls the latest changes.
  diff                                             Shows the colorized diff of the repository.
  delete                                           Deletes specified files from the repository.

EOF
}

help_command() {
    case "$1" in
        identity)
            echo "Usage: $0 identity -p <provider> -e <email> -u <username>"
            echo "Creates an SSH identity for the specified provider."
            ;;
        init)
            echo "Usage: $0 init"
            echo "Initializes an empty Git repository."
            ;;
        status)
            echo "Usage: $0 status"
            echo "Shows the status of the current repository."
            ;;
        commit)
            echo "Usage: $0 commit"
            echo "Creates a new commit with a unique ID and a commit message."
            ;;
        merge)
            echo "Usage: $0 merge <destination-branch>"
            echo "Merges the specified branch into the current branch."
            ;;
        push)
            echo "Usage: $0 push"
            echo "Pushes the current branch to the remote repository."
            ;;
        check)
            echo "Usage: $0 check <file>"
            echo "Displays the contents of the specified file."
            ;;
        fp)
            echo "Usage: $0 fp"
            echo "Fetches all branches and pulls the latest changes."
            ;;
        diff)
            echo "Usage: $0 diff"
            echo "Shows the colorized diff of the repository."
            ;;
        delete)
            echo "Usage: $0 delete"
            echo "Deletes specified files from the repository."
            ;;
        *)
            echo "No help available for $1"
            ;;
    esac
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
        B=$(($RANDOM % 256))

        if ((N == 6)); then
            printf '4%x' $((B % 16))
        elif ((N == 8)); then
            local C='89ab'
            printf '%c%x' ${C:$(($RANDOM % ${#C})):1} $((B % 16))
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
    DESTINATION_BRANCH=$1

    if [[ ! $DESTINATION_BRANCH ]]; then
        echo ${red}"You need to specify the branch you want to merge."${reset}
        exit 1
    fi

    printf "Select which version control you are currently using: (g)it, (s)ubversion. "
    read ans || return 1
    case "$ans" in
        [gitGIT]*)
            echo "Using GIT"
            CURRENT_BRANCH=$(git branch --show-current)

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
}

# Initialize .git directory in current folder
init() {
    mkdir -p -m 777 .git
    declare -a references=("objects" "refs" "refs/heads")
    for name in "${references[@]}"; do
        mkdir .git/${name}
    done

    touch .git/.repos
    echo "0" > .git/.repos
    echo "ref: refs/heads/master" > .git/HEAD
    echo "initialized empty repository."
}

set_identity() {
    dir="$HOME/.ssh"
    provider=""
    email=""
    username=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--provider)
                provider="$2"
                shift
                shift
                ;;
            -e|--email)
                email="$2"
                shift
                shift
                ;;
            -u|--username)
                username="$2"
                shift
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    if [ -n "$provider" ] && [ -n "$email" ] && [ -n "$username" ]; then
        if [ ! -d $dir ]; then
            mkdir -p $dir
        fi

        ssh-keygen -t ed25519 -C "$email" -N "" -f "$HOME/.ssh/id_${provider}_${username}" <<<y >/dev/null 2>&1

        config_entry="
Host ${provider}
    User ${username}
    IdentityFile $HOME/.ssh/id_${provider}_${username}
    IdentitiesOnly yes
"

        if [ ! -f $HOME/.ssh/config ]; then
            echo "$config_entry" > $HOME/.ssh/config
        else
            grep -q "$provider" $HOME/.ssh/config || echo "$config_entry" >> $HOME/.ssh/config
        fi
    else
        printf "${red}To use this command, please, pass the flags (-p)rovider, (-e)mail and (-u)sername.${reset}\n"
    fi
}

status() {
    printf "Select which version control you are currently using: (g)it, (s)ubversion. "
    read ans || return 1
    case "$ans" in
        [gitGIT]*)
            echo "Using GIT"
            git status
            return 0
            ;;
        *)
            printf "${red}Please, select a valid version control system...${reset}\n"
            exit 1
            ;;
    esac
}

search_repo() {
    cat .git/.repos
    return 0
}

commit() {
    commit_id="$(uuid)"
    timestamp=$(date +%T)
    read -p "Enter commit message: " commit_message

    if [[ ! $commit_message ]]; then
        echo "Please, enter a commit message..."
        exit 1
    fi

    echo "Created commit with id: $commit_id"
    echo "Commit message: $commit_message"
    echo "Created at: $timestamp"
    # Assuming you want to record this in a log
    echo "$commit_id - $commit_message - $timestamp" >> .git/commit_log
}

push_to_vcs() {
    printf "Add all unstaged files? (y)es, (n)o? "
    read stagedFilesAnswer || return 1
    case "$stagedFilesAnswer" in
        [yY]*)
            echo "Adding files..."
            git add .
            ;;
        [nN]*)
            echo "Please, select files to add: "
            read -e files_to_add
            git add $files_to_add
            ;;
        *)
            printf "${red}Please, select a valid option... (y)es or (n)o${reset}\n"
            exit 1
            ;;
    esac

    read -p "Enter commit message: " commit_message

    git commit -m "$commit_message"

    printf "Select branch to push to: \n"
    git branch
    read branchAns || return 1
    case "$branchAns" in
        *)
            echo "Pushing to $branchAns..."
            git push origin $branchAns
            ;;
    esac

    echo "Done!"
    return 0
}

cat_file_contents() {
    if [[ ! $1 ]]; then
        printf "${red}Please, enter the name of the file you want to check.${reset}\n"
        return 1
    fi

    find . -name "$1*" -type f | xargs less -R
}

fetch_all_and_pull() {
    git fetch --all && git pull
}

color_diff() {
    git diff --color > colordiff.txt
    less colordiff.txt
    rm colordiff.txt
}

remove_files() {
    printf "${red}Are you sure you want to PERMANENTLY DELETE those files?${reset}\n"
    read -p "Enter file names: " filesAns || return 1
    case "$filesAns" in
        *)
            echo "Deleting $filesAns"
            rm -f $filesAns
            ;;
    esac

    return 0
}

if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

for ARG in "$@"; do
    case "$ARG" in
    identity)
        set_identity "$@"
        exit 0
        ;;
    init)
        init
        exit 0
        ;;
    status)
        status
        exit 0
        ;;
    commit)
        commit
        exit 0
        ;;
    merge)
        prompt_merge "$2"
        exit 0
        ;;
    push)
        push_to_vcs
        exit 0
        ;;
    check)
        cat_file_contents "$2"
        exit 0
        ;;
    fp)
        fetch_all_and_pull
        exit 0
        ;;
    diff)
        color_diff
        exit 0
        ;;
    delete)
        remove_files
        exit 0
        ;;
    help)
        usage
        exit 0
        ;;
    -h|--help)
        if [[ $# -gt 1 ]]; then
            help_command "$2"
            exit 0
        else
            usage
            exit 0
        fi
        ;;
    *)
        usage
        exit 0
        ;;
    esac
done

