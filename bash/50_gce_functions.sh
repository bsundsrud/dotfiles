#!/bin/bash
function context {

  GREEN=$(tput setaf 2)
  RESET=$(tput sgr0)

  if [[ -n $1 ]]; then
    kubectl config use-context $1 &> /dev/null
  fi

  contexts=$(kubectl config get-contexts -o name | sort)
  current_context=$(kubectl config current-context)

  for c in $contexts; do
    if [ "$c" = "$current_context" ]; then
      printf "%s " "${GREEN}[${c}]${RESET}"
    else
      printf "%s " $c
    fi
  done

  echo 
}

function ns {
  if [[ -n $1 ]]; then
    if [[ "$1" == "unset" ]] ; then
      kubectl config set-context $(kubectl config current-context) --namespace=
    else
      kubectl config set-context $(kubectl config current-context) --namespace=$1
    fi
  fi

  namespaces=$(kubectl get namespaces -o name | sed -e 's/namespace\///g' | sort)
  current_context=$(kubectl config current-context)
  current_namespace=$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${current_context}\")].context.namespace}")

  for c in $namespaces; do
    if [ "$c" == "$current_namespace" ]; then
      printf "\033[31m[\033[0m\033[33m%s\033[0m\033[31m]\033[0m " $c
    else
      printf "%s " $c
    fi
  done
  
  echo
}

function project {

  if [[ -n $1 ]]; then
    if gcloud config configurations describe $1 &> /dev/null; then
      gcloud config configurations activate $1
    else
      echo "$1 is not configured. Set it up? (Y/n)"
      read response
      case "$response" in
        [nN][oO]|[nN])
          echo "exiting"
          exit 0
          ;;
        *)
          echo "enter account we will use to access $1: "
          read email
          if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
            cat << EOF > ${HOME}/.config/gcloud/configurations/config_$1
[core]
account = $email
project = $1

EOF
            gcloud config configurations activate $1
          else
            echo "Email address $email is invalid."
            exit 1
          fi
          ;;
      esac
    fi
  else

    projects=$(gcloud config configurations list | awk '/True|False/ {print $1}' | sort)
    current_project=$(gcloud config configurations list | awk '/True/ {print $1}')

    for c in $projects; do
      if [ "$c" = "$current_project" ]; then
        printf "\033[31m[\033[0m\033[33m%s\033[0m\033[31m]\033[0m " $c
      else
        printf "%s " $c
      fi
    done

    echo
  fi
}
if which kubectl > /dev/null 2>&1; then
    source <(kubectl completion bash)
fi

