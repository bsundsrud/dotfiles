#!/bin/bash

function workon() {

    function usage() {
        echo "Usage: workon [-u] GITHUB_PATH" 1>&2
    }

    DEFAULT_PROJECT_HOME="$HOME/devel"
    if [ -z "$WORKON_PROJECT_HOME_DIR" ]; then
        WORKON_PROJECT_HOME_DIR="$DEFAULT_PROJECT_HOME"
    fi

    function abs_project_path() {
        local ns="$1"
        local project="$2"
        echo "$WORKON_PROJECT_HOME_DIR/$ns/$project"
    }

    function use_ssh_for_namespace() {
        local ns="$1"
        if [[ "$WORKON_SSH_PROJECTS" == *"$ns"* ]]; then
            return 0
        else
            return 1
        fi
    }

    function github_clone() {
        local namespace="$1"
        local project="$2"
        local project_dir
        project_dir="$(abs_project_path "$namespace" "$project")"
        echo "Cloning new project..."
        if use_ssh_for_namespace "$namespace"; then
            git clone "git@github.com:$namespace/${project}.git" "$project_dir"
        else
            git clone "https://github.com/$namespace/${project}.git" "$project_dir"
        fi
    }

    function update_existing() {
        local namespace="$1"
        local project="$2"
        local project_dir
        project_dir="$(abs_project_path "$namespace" "$project")"
        echo "Updating existing project..."
        git -C "$project_dir" fetch -a
    }

    function main() {
        local path="$1"
        local do_update="$2"
        local namespace
        namespace="$(dirname "$path")"
        local project
        project="$(basename "$path")"
        local project_dir
        project_dir="$(abs_project_path "$namespace" "$project")"
        if [ -d "$project_dir" ]; then
            if [ "$do_update" = "1" ]; then
                update_existing "$namespace" "$project"
            fi
        else
            github_clone "$namespace" "$project"
        fi
        cd "$project_dir" || return 1
    }
    update_opt="0"
    while getopts ":hu" o; do
        case "${o}" in
            u)
                update_opt="1"
                ;;
            h)
                usage
                return 0
                ;;
            *)
                usage
                return 1
                ;;
        esac
        shift
    done
    if [ -z "$1" ]; then
        usage
        return 1
    fi
    main "$1" "$update_opt"
}

