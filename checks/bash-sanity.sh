#!/usr/bin/env bash
set -euo pipefail

dir="$1"

# Do some basic sanity checks on the bash scripts in this repository.
# We expect the following:
# - All scripts must use the shebang `#!/usr/bin/env bash`.
# - All scripts must have the execute permission set.
# - All scripts must set the `-euo pipefail` options immediately after the shebang.
# - If the script is too long, I'm going to question your sanity.

# Additional checks are provided by shellcheck, which runs as part of `nix fmt`.

# Maximum number of lines allowed in a script.
MAX_LINES=100

error() {
  echo "$1" >&2
}

check_shebang() {
  file="$1"
  head -n 1 "$file" | grep -q '^#!/usr/bin/env bash' || return 1
}

check_permissions() {
  file="$1"
  [[ -x "$file" ]]
}

check_options() {
  file="$1"
  head -n 2 "$file" | grep -q 'set -euo pipefail' || return 1
}

check_length() {
  file="$1"
  lines=$(wc -l < "$file")
  [[ "$lines" -le "$MAX_LINES" ]]
}

check_file() {
  file="$1"
  bad=0
  check_shebang "$file" || {
    error "Missing shebang: $file"
    bad=1
  }
  check_permissions "$file" || {
    error "Missing execute permission: $file"
    bad=1
  }
  check_options "$file" || {
    error "Missing safe mode: $file"
    bad=1
  }
  check_length "$file" || {
    error "Excessive script length: $file"
    bad=1
  }
  return $bad
}

any_bad=0
while IFS= read -r -d '' file; do
  check_file "$file" || {
    error "$file failed checks."
    any_bad=1
  }
done < <(find "$dir" -type f -name '*.sh' -print0)

exit $any_bad
