#!/usr/bin/env bash
set -euo pipefail

MIN=0.2
MAX=1.0
STATEFILE=/tmp/brightness

STEPS=10
DISPLAYS=$(xrandr --query | grep ' connected' | awk '{print $1}')

showhelp() {
  cat <<EOF
Usage: $0 [amount]
  -h|--help:
    Show this help message and exit

Adjust screen brightness by [amount], where [amount] is a multiplier of the default
Capped to between $MIN and $MAX
EOF
  exit
}

adjust=''
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      showhelp
      ;;
    *)
      adjust="$1"
      ;;
  esac
  shift
done

if [[ -z "$adjust" ]]; then
  showhelp
fi

current=$(if [[ -f $STATEFILE ]]; then cat $STATEFILE; else echo 1.0; fi)
newvalue=$(awk -v c="$current" -v a="$adjust" -v min="$MIN" -v max="$MAX" 'BEGIN {
  result = c + a;
  if (result < min) result = min;
  if (result > max) result = max;
  print result;
}')
echo "$newvalue" > "$STATEFILE"
echo "Adjusting brightness from $current to $newvalue on displays $(tr '\n' ' ' <<< "$DISPLAYS")"

stepsize=$(awk -v c="$current" -v n="$newvalue" -v s="$STEPS" 'BEGIN {print (n - c) / s}')

for ((step=0; step<STEPS; step++)); do
  intermediate=$(awk -v c="$current" -v s="$stepsize" -v i="$step" 'BEGIN {print c + (s * i)}')

  while read -r display; do
    xrandr --output "$display" --brightness "$intermediate"
  done <<<"$DISPLAYS"
  # xrandr is fairly slow, so use that on its own as a delay time
  # sleep $STEPDELAY
done
