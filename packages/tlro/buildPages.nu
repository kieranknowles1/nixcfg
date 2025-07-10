#!/usr/bin/env nu

def main [
  src: path
  dest: path
] {
  cd $src
  ls pages.*/**/*.md | get name | each {
    let split = $in | split row '/'
    {
      name: ($split.2 | str replace '.md' '')
      language: ($split.0 | str replace 'pages.' '')
      platform: ($split.1)
      contents: (open $in)
    }
  } | into sqlite $dest --table-name pages

  # Queries will use the composite index if they provide a prefix of the columns
  # from left to right. Skipping a column requires skipping the rest of the index.
  open $dest | query db "CREATE UNIQUE INDEX idx_pages ON pages (name, language, platform)"

  return
}
