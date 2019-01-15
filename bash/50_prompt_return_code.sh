_prompt_return_code() {
    ret="$?"
    if [[ -z "$ret" || "$ret" == "0" ]]; then
        echo "${C_DGREEN}✓${C_RESET}  "
    else
        printf "${C_LRED}%-3s${C_RESET}" "$ret"
    fi
}
