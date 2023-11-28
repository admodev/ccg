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
    dir="$HOME/.ssh"
    provider=""
    email=""
    username=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--provider)
                echo "Provider set"
                PROVIDER="$2"
                shift
                shift
                ;;
            -e|--email)
                echo "Email set"
                EMAIL="$2"
                shift
                shift
                ;;
            -u|--username)
                echo "Username set"
                USERNAME="$2"
                shift
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    if [ -n "$PROVIDER" ] && [ -n "$EMAIL" ] && [ -n "$USERNAME" ]; then
        echo "The provider is: $PROVIDER"
        echo "The email is: $EMAIL"
        echo "The provider is: $USERNAME"

        if [ ! -d $dir ]; then
            mkdir $dir
        fi

        ssh-keygen -t ed25519 -C "$email" -N "" -f "$HOME/id_rsa" <<<y >/dev/null 2>&1

        if [ ! -f $HOME/.ssh/config ]; then
            cat > $HOME/.ssh/config <<- EOM
        Host $1
        User $USERNAME
        IdentityFile $HOME/.ssh/${USERNAME}_${PROVIDER}
        IdentitiesOnly yes
EOM
        else
            # NOTE: tee command only works on unix/linux.
            tee -a $HOME/.ssh/config <<EOM
        Host $1
        User $USERNAME
        IdentityFile $HOME/.ssh/${USERNAME}_${PROVIDER}
        IdentitiesOnly yes
EOM
        fi
    else
        printf "${RED}To use this command, please, pass the flags (-p)rovider, (-e)mail and (-u)sername.${RESET}\n"
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

push_to_vcs() {
    while true
    do
        printf "Add all unstaged files? (y)es, (n)o? "
        read stagedFilesAnswer || return 1
        case "$stagedFilesAnswer" in
            [yY]*)
                echo "Adding files..."
                git add .
                ;;
            [nN]*)
                echo "Please, select files to add: "
                ;;
            *)
                printf "${red}Please, select at least one valid answer... (y)es or (n)o${reset}"

                exit 1
                ;;
        esac

        read -p "Enter commit message: " commit_message

        git commit -m commit_message

        printf "Select branch: \n"
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
    done
}

# Check content of a file before adding it to vc
cat_file_contents() {
    if [[ ! $1 ]]; then
        printf "${red}Please, enter the name of the file you want to check.${reset}\n"
        return 1
    fi

    find -name $1* -type f | xargs less -R
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

  read filesAns || return 1
    case "$filesAns" in
      *)
        echo "Deleting"
        ls
        ;;
    esac

    return 0
}

for ARG in ${@}; do
    case "$ARG" in
    "identity")
        set_identity "$@"
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
    "push")
        push_to_vcs
        ;;
    "check")
        cat_file_contents $2
        ;;
    "fp")
      fetch_all_and_pull
      ;;
    "diff")
      color_diff
      ;;
    "delete")
      remove_files
      ;;
    "help")
        usage
        ;;
    *)
        usage
        ;;
    esac
done

if [ $# -eq 0 ]; then
    usage
fi
