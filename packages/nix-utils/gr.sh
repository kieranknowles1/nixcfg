#!/usr/bin/env bash
set -euo pipefail

mode="${1:-help}"

showHelp() {
  cat <<EOF
Usage: $0 [mode]

Possible modes:
- url: Get the URL for the remote repository
- pr: Open a form to submit a pull request in the browser
EOF
}

# Get the remote repo URL, assuming GitHub style paths
getUrl() {
  git remote get-url origin | sed -E 's|git@(.+):(.+)|https://\1/\2|'
}

createPullRequest() {
  branch="$(git branch --show-current)"
  if [[ "$branch" == "main" || "$branch" == "master" ]]; then
    echo "Cannot create a pull request without first creating a new branch" 1>&2
    return 1
  fi

  xdg-open "$(getUrl)/compare/$branch"
}

case "$mode" in
  "help" | "-h" | "--help")
    showHelp
  ;; "url")
    getUrl
  ;; "pr")
    createPullRequest
  ;; *)
    showHelp
    exit 1
esac
