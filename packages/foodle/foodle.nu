#!/usr/bin/env nu

const TEMPLATE_ID = "OwQeRC3WIXq6"
const DAY_TEMPLATE_ID = "EbY1qa6quEOD"

const VERSION_CAFFEINE_TRACK = 3

# Get all notes in a flat list
def walk_meta [] {
  let children = $in | get --optional children
  let self = $in | reject --optional children
  if $children == null {
    [$self]
  } else {
    [$self] ++ ($children | each {walk_meta} | flatten)
  }
}

# Convert a list of notes to a dictionary with noteId as key
def flatten_meta [] {
  $in | each {|it| [
    $it.noteId
    $it
  ]} | into record
}

# Find an attribute or relation by name, or null if not found
# If an attribute exists multiple times, return the first one
def get_attribute_value [
  name: string
] {
  let matches = $in.attributes | where name == $name
  if $matches == [] {
    null
  } else $matches.0.value
}

# Get the full path to a note as a list of elements
def full_path [
  by_id: record
] {
  let directories = $in.notePath | drop | each {|it| $by_id | get $it | get dirFileName}
  let datName = $in.dataFileName

  $directories | append $datName
}

def first_word [] {
  split words | first | into int
}

# Get the date of a note based on its path entries
def date [] {
  # Entries follow the form:
  # ["Root" "Calendar" "2025" "06 - June" "26 - Thursday" "Foods.md"]

  let parts = $in | drop 1 | last 3
  {
    year: ($parts.0 | into int),
    month: ($parts.1 | first_word),
    day: ($parts.2 | first_word)
  } | into datetime
}

# Clean up exported text
def cleanup_text [] {
  # Remove <a> tags but not their contents, as these refer to notes that will not
  # be available in the CSV
  str replace --regex --all '<a.+?>(.+?)</a>' "$1"
  # Remove non-breaking spaces, Trilium prepends links with these
    | str replace "\u{A0}" " "
}

def parse_note [] {
  # Contents represents a markdown file that ends in a 3-row table, which
  # is the only part we're interested in
  let contents = open ($in.path | str join "/") | cleanup_text
  let datestr = $in.date | format date "%Y-%m-%d"
  let version = $in | get_attribute_value version | default 0 | into int

  # Row format: [Time, Food, Caffeine, Medical Notes]
  $contents | lines | last 3 | each {
    let items = split row "|" | drop nth 0 | drop | str trim
    {
      day: $datestr,
      time: $items.0,
      food: $items.1,
      caffeine: (if $version >= $VERSION_CAFFEINE_TRACK {$items.2} else {""}),
      medical: (if $version >= $VERSION_CAFFEINE_TRACK {$items.3} else {$items.2})
    }
    # $items | prepend $datestr
  }
}

# Food diary exporter from Trilium to CSV
# Setting Trilium up for this isn't fully documented, but here's some brief instructions:
# - Create template for calendar notes
# - Add "Foods" subnote of "Day", referencing a template
# - Set food subnote version to 4
# - Copy in `food-template.md` to the food subnote
# Feel free to contact me if this sounds useful
def main [
  directory: string = ./
] {
  cd $directory
  let notes = open "!!!meta.json" | get files.0 | walk_meta
  let by_id = $notes | flatten_meta

  let food_entries = $notes
    | where title == "Foods"
    # Get all food entry notes, except for the one in the "Day" template
    | where {|x| ($x |get_attribute_value "template") == $TEMPLATE_ID}
    | where noteId != $DAY_TEMPLATE_ID
    | insert path {full_path $by_id}
    | insert date {get path | date}
    | sort-by date

  $food_entries | each {parse_note} | flatten | to csv
}
