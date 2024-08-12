#!/usr/bin/env bash

# Quick and dirty command palette. Takes a list of commands and descriptions,
# then lets the user choose one to run. Useful for the midpoint between
# rare enough for a CLI, but not common enough to warrant a dedicated binding.
# Intended to be bound to a key

if [[ "$#" -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
  cat <<EOF
Usage: $0 actions_file
  Where actions_file is a text file in the format:
  action1
  description1
  action2
  description2
  ...

Presents the list of actions to the user, then runs the selected one.
If the command has output, it will be shown in a notification.
EOF

  exit 0
fi
actions_file=$1

# Read the actions file into an array
# Yes, this is a terrible format, but this script is pushing the limits of
# what bash should be used for.
# TODO: Rust IV - A new Crate
readarray -t commands < "$actions_file"

# Run zenity to get the user's choice
# We hide the first column, which is the command to run. When selected, this
# hidden column is printed to stdout which we capture in $choice
status=0
choice=$(zenity --list --hide-column=1 --print-column=1 \
    --title="Command Palette" --text="Choose an action" \
    --column="Action" --column="Description" "${commands[@]}"
) || status=$?
# https://stackoverflow.com/questions/11231937/bash-ignoring-error-for-a-particular-command
# || status=$? is a trick to capture the exit status of the zenity command, without
# exiting a script with set -e

# If the user cancelled, exit. Not considered an error as it's a valid action
if [ "$status" -ne 0 ]; then
  echo "User cancelled"
  exit
fi

# $choice is the action we want to run. Since we don't have a terminal
# to show the output, we'll capture it and display it in a notification
# Bash doesn't have a clean way to capture both stdout and stderr into
# separate variables, so we'll combine them into a single variable
status=0
output=$($choice 2>&1) || status=$?

if [ "$status" -ne 0 ]; then
  # Something went wrong, show an error dialog
  zenity --error --text="Error running command:\n$output"
elif [ -n "$output" ]; then
  # We're successful and have output to show
  zenity --info --text="$output"
fi
