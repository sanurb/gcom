#!/bin/bash

print_colorful_message() {
    color_code=$1
    message=$2
    echo -e "\033[${color_code}m${message}\033[0m"
}

check_git_repository() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        print_colorful_message "31" "Not a git repository. Exiting."
        exit 1
    fi
}

get_current_folder_name() {
    basename "$(pwd)"
}

backup_commit() {
    folder=$(get_current_folder_name)
    timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    print_colorful_message "34" "Committing Backup for $folder"
    git add .
    git commit -m "backup: ${timestamp}"
}

batch_commit() {
    print_colorful_message "34" "Batch Committing: $(get_current_folder_name)"
    for file in *; do
        if [[ -f $file ]]; then
            git add "$file"
            print_colorful_message "32" "feat: add $file"
            git commit -m "feat: add $file"
        fi
    done
}


select_commit() {
    check_git_repository
    git status --short
    print_colorful_message "34" "Select files to add by typing their names, separated by space:"
    read -ra files_to_add
    for file in "${files_to_add[@]}"; do
        if [[ -f $file ]]; then
            git add "$file"
            print_colorful_message "32" "Added $file"
        else
            print_colorful_message "31" "$file is not a valid file."
        fi
    done
    print_colorful_message "34" "Enter commit message:"
    read -r commit_msg
    git commit -m "$commit_msg"
}

sync_commit() {
    check_git_repository
    git pull --rebase --autostash
    backup_commit
    git push
}

browse_recent_branches() {
    check_git_repository

    if ! command -v fzf >/dev/null 2>&1; then
        print_colorful_message "31" "Error: fzf is not installed. Please install fzf to use this feature."
        exit 1
    fi

    print_colorful_message "34" "Fetching recent branches..."
    
    origin_HEAD=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

    chosen_branch=$(git for-each-ref --color=always --sort=-committerdate refs/heads/ \
        --format="%(color:yellow)%(refname:short)%(color:reset)" | \
        fzf --ansi --layout=reverse --height=90% --min-height=20 \
            --border-label "🌿 Recent Branches" --border \
            --preview "git log --oneline --graph --color=always --decorate {1}" \
            --bind "ctrl-o:execute(git diff --color=always $origin_HEAD...{1} | less -R)")

    if [[ -n "$chosen_branch" ]]; then
        print_colorful_message "32" "Switching to branch: $chosen_branch"
        git checkout "$chosen_branch"
    fi
}

show_help() {
    echo "Usage: $(basename "$0") [OPTION]"
    echo "  -a      Commit all files in separate commits"
    echo "  -b      Commit all files in a backup commit"
    echo "  -s      Sync commits (pull, backup commit, push)"
    echo "  -r      Browse and checkout recent branches using fzf"
    echo "  -h      Show this help message"
}

case $1 in
    -a) batch_commit ;;
    -b) backup_commit ;;
    -s) sync_commit ;;
    -r) browse_recent_branches ;;
    -h | --help) show_help ;;
    *) select_commit ;;
esac
