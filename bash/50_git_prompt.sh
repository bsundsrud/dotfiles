_git_prompt_status() {
    status_output="$(git status --porcelain --branch 2>/dev/null)"
    exit_code=$?
    if [ $exit_code -gt 0 ]; then
        return $exit_code
    fi
    branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    exit_code=$?
    if [[ $exit_code -gt 0 ]]; then
        # we must be in a new repo with no commits
        branch="${C_DRED}master${C_RESET}"
    elif [[ "$branch" == "HEAD" ]]; then
        branch="${C_DRED}{$(git rev-parse --short HEAD 2>/dev/null)}${C_RESET}"
    fi

    untracked="$(echo "$status_output" | grep '^??' | wc -l)"
    modified="$(echo "$status_output" | grep '^.M' | wc -l)"
    added="$(echo "$status_output" | grep '^[AM]' | wc -l)"
    deleted="$(echo "$status_output" | grep '^\(.D\|D.\)' | wc -l)"
    stashed="$(git stash list | wc -l)"
    upstream="$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)"
    upstream_line=""
    if [[ -n "$upstream" ]]; then
        relative_output="$(git rev-list --count --left-right "$upstream"...HEAD 2>/dev/null)"
        them="$(echo "$relative_output" | cut -f1)"
        us="$(echo "$relative_output" | cut -f2)"
        relative=""
        if [[ -n "$them" && "$them" -gt 0 ]]; then
            relative="${C_LRED}↓${them}${C_RESET}"
        fi
        if [[ -n "$us" && "$us" -gt 0 ]]; then
            relative="${relative}${C_DGREEN}↑${us}${C_RESET}"
        fi
        if [[ -n "$relative" ]]; then
            relative=" $relative"
        fi
        
        upstream_line="${C_LCYAN}${upstream}${C_RESET}${relative}"
    fi
    if [[ "$untracked" -gt 0 ]]; then
        untracked=" ${C_LBLUE}${untracked}?${C_RESET}"
    else
        untracked=""
    fi
    if [[ "$modified" -gt 0 ]]; then
        modified=" ${C_DYELLOW}${modified}*${C_RESET}"
    else
        modified=""
    fi
    if [[ "$added" -gt 0 ]]; then
        added=" ${C_DGREEN}${added}✓${C_RESET}"
    else
        added=""
    fi
    if [[ "$deleted" -gt 0 ]]; then
        deleted=" ${C_DRED}${deleted}×${C_RESET}"
    else
        deleted=""
    fi
    if [[ "$stashed" -gt 0 ]]; then
        stashed=" ${C_LMAGENTA}${stashed}💩${C_RESET}"
    else
        stashed=""
    fi
    
    status_line="${untracked}${modified}${added}${deleted}${stashed}"
    if [[ -n "$relative" ]]; then
        relative=" $relative"
    fi
    
    if [[ -n "$upstream_line" ]]; then
        upstream_line="($upstream_line) "
    fi
    
    printf "${upstream_line}[${C_LYELLOW}${branch}${C_RESET}${status_line}]"
}

