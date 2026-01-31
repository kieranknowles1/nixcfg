#!/usr/bin/env bash
set -euo pipefail

mode="${1:-help}"

showHelp() {
  cat <<EOF
Usage: $0 [mode]

Possible modes:
- open: Open the remote in the default browser
- pr: Open a form to submit a pull request in the browser
- url: Get the URL for the remote repository
EOF
}

# Get the remote repo URL, assuming GitHub style paths
getUrl() {
  git remote get-url origin | sed -E \
    -e 's|^git@(.+):(.+)|https://\1/\2|' \
    -e 's|\.git$||'
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
  ;; "open")
    xdg-open "$(getUrl)"
  ;; "pr")
    createPullRequest
  ;; "url")
    getUrl
  ;; *)
    showHelp
    exit 1
esac
