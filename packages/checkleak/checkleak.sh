#!/usr/bin/env bash
set -euo pipefail

# Environment (set by Nix):
#  TARGET - executable to build/run
#  SUPPRESSIONS - array of suppression files

showhelp() {
  cat <<EOF
Usage: $0 [tool=memcheck]
  -h|--help:
    Show this help message and exit
  -s|--strict:
    Exit on first error
  -S|--suppressions:
    Generate suppressions
EOF
}

opts=()
errexit=no
tool=memcheck
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      showhelp
      ;;
    -s|--strict)
      errexit=yes
      ;;
    -S|--suppressions)
      opts+=( "--gen-suppressions=yes" )
      ;;
    *)
      tool=$1
      ;;
  esac
  shift
done


case $tool in
  memcheck)
    opts+=( "--leak-check=full" )
    ;;
esac

cmake -DCMAKE_BUILD_TYPE=Debug build
make --directory build -j12 $TARGET

# TODO: Set target path automatically
# TODO: Detect extra suppressions
valgrind --tool="$tool" --error-exitcode=1 --exit-on-first-error=$errexit \
  "${SUPPRESSIONS[@]}" "${opts[@]}" ./build/TeamProject/$TARGET
