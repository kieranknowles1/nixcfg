#!/usr/bin/env nu

const TEMPLATE_ID = "EbY1qa6quEOD"

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

def main [] {
  let notes = open "!!!meta.json" | get files.0 | walk_meta
  let by_id = $notes | flatten_meta

  let food_entries = $notes
    | where title == "Foods"
    | where {|x| ($x |get_attribute_value "template") != null}
    | where noteId != $TEMPLATE_ID
    | insert path {full_path $by_id}
    | insert date {get path | date}

  $food_entries | save out.json -f
}
