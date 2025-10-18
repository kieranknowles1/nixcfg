#!/usr/bin/env bash
set -euo pipefail

DEFAULT_PLATFORM=$PLATFORM

# May be set by Nix
SHORTOPTS=${SHORTOPTS:-0}
LONGOPTS=${LONGOPTS:-0}

showhelp() {
  shortOptDefault=$([[ $SHORTOPTS == 1 ]] && echo " (default)" || echo "")
  longOptDefault=$([[ $LONGOPTS == 1 ]] && echo " (default)" || echo "")

  cat <<EOF
Offline-only TLDR client

Usage: $0 [command]
  -h|--help:
    Show this help message and exit
  -v|--version:
    Show the version number and exit
  -p|--platform:
    Set the platform to use by default (Default: $PLATFORM)
  --platforms:
    List all available platforms
  --languages:
    List all available languages
  -L|--language:
    Set the language to use by default (Default: $LANGUAGE)
  -l|--list
    List all the pages to the standard output.
    If a command is provided, filter pages based on it.
  --short-options:
    Show short-form options if available$shortOptDefault
  --long-options:
    Show long-form options if available$longOptDefault

  If both '--short-options' and '--long-options' are passed, then
  both will be shown.
EOF
  exit
}

# Short/long-form arguments in the form {{[short|long]}}
SED_ARGUMENT_PATTERN='\{\{\[([a-zA-Z -]+)\|([a-zA-Z -]+)\]\}\}'

query=""
list=0
shortopts=0
longopts=0
platforms=0
languages=0
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      showhelp
      ;;
    -v|--version)
      echo "tlro version $VERSION, client specification 2.3"
      exit
      ;;
    -p|--platform)
      PLATFORM="$2"
      shift
      ;;
    -L|--language)
      LANGUAGE="$2"
      shift
      ;;
    -l|--list)
      list=1
      ;;
    --platforms)
      platforms=1
      ;;
    --languages)
      languages=1
      ;;
    --short-options)
      shortopts=1
      arg_replace='\1'
      ;;
    --long-options)
      longopts=1
      arg_replace='\2'
      ;;
    -*)
      echo "Unknown flag '$1'" >&2
      exit 1
      ;;
    *)
      query="$query-${1// /-}"
      ;;
  esac
  shift
done
# Remove leading dashes from when we appended
query="${query#-}"

filterLanguage="language IN ('en', '$LANGUAGE')"

if [[ "$platforms" == 1 ]]; then
  sqlite3 "$PAGES" "SELECT DISTINCT platform FROM pages WHERE $filterLanguage ORDER BY platform"
  exit
elif [[ "$languages" == 1 ]]; then
  sqlite3 "$PAGES" "SELECT DISTINCT language FROM pages ORDER BY language"
  exit
elif [[ "$list" == 1 ]]; then
  # We use grep instead of WHERE to highlight matching pages
  sqlite3 "$PAGES" "SELECT DISTINCT name FROM pages WHERE $filterLanguage AND platform = '$PLATFORM' OR '$PLATFORM' = '$DEFAULT_PLATFORM' ORDER BY name" | grep --color "$query"
  exit
fi

if [[ "$query" == "" ]]; then
  showhelp
fi

if [[ "$shortopts" == 0 && "$longopts" == 0 ]]; then
  shortopts=$SHORTOPTS
  longopts=$LONGOPTS
fi

if [[ "$shortopts" == 1 && "$longopts" == 1 ]]; then
  arg_replace='[\1|\2]' # Show both, surrounded by [] and separated by a pipe
elif [[ "$shortopts" == 1 ]]; then
  arg_replace='\1'
else
  arg_replace='\2'
fi

# TODO: Add TLDR pages based on meta attributes of my packages, will need restructuring to fit in with the standard

result=$(sqlite3 -json "$PAGES" <<SQL
  SELECT language, platform, contents FROM pages WHERE $filterLanguage AND name = '$query'
    ORDER BY
      -- Check the platform on which we are running first, try common second, then other platforms in an unspecified order
      (CASE WHEN platform = '$PLATFORM' THEN 100 WHEN platform = 'common' THEN 50 ELSE 0 END) +
      -- Check the user's language first, showing the localised page if available even if it is not platform-specific
      (CASE WHEN language = '$LANGUAGE' THEN 200 ELSE 0 END)
    DESC LIMIT 1
SQL
)

if [[ "$result" = "" ]]; then
  echo "Page '$query' not found." >&2
  exit 1
fi

finalPlatform=$(jq -r '.[0].platform' <<< "$result")
if [[ "$finalPlatform" != "$PLATFORM" && "$finalPlatform" != "common" ]]; then
  echo "WARNING: Page '$query' is not available on platform '$PLATFORM'. Using version from '$finalPlatform' instead."
fi

contents=$(jq -r '.[0].contents' <<< "$result")
# Reformat things a bit
# 1. Only show short/long-form versions of arguments accodring to $LONGOPTS
# 2. Replace example code blocks with bold (we're on the terminal, so assume a monospaced font)
# 3. Show editable placeholders as code blocks (mdcat uses orange for these)
# $ is being used as part of the sed expression, not for variable expansion
# shellcheck disable=SC2016
sed --regexp-extended "s/$SED_ARGUMENT_PATTERN/$arg_replace/" <<< "$contents" \
  | sed --regexp-extended 's|^`(.+)`$|**\1**|' \
  | perl -pe 's|\{\{(.+?)\}\}|`\1`|g' \
  | mdcat
