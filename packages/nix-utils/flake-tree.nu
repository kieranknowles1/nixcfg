#!/usr/bin/env nu

# TODO: Package this up. May want to load from config.nu to allow
# completions

# Given a value from the "inputs" field of a flake.lock entry,
# get tge target key of "nodes" that it refers to
def get-target [] {
  let raw = $in
  let type = $raw | describe -d | get type
  match $type {
    # Non-overridden inputs (lacking inputs.name.follows) are represented as strings
    "string" => $raw,
    # Overridden inputs are arrays of strings? (I think)
    # In any case, the last element is the target
    # And an empty array represents a null input (inputs.name.follows = "")
    "list" => {
      if (($raw | length) > 0) {
        $raw | last
      } else {
        null
      }
    }
  }
}

# Try to get a node with its dependencies resolved
# Returns null if the node doesn't exist or explicitly
# points to null
def resolve-dep [
  nodes: record
] {
  let name = $in

  if ($name == null) {
    null
  } else if ($name in $nodes) {
    $nodes | get $name | resolve-deps $nodes
  } else {
    null
  }
}

# Recursively resolve inputs to their dependencies
def resolve-deps [
  nodes: record
] {
  let node = $in

  if ("inputs" in $node) {
    $node.inputs | transpose k v | each {|it|
      let target = $it.v | get-target
      [$target ($target | resolve-dep $nodes)]
    } | where {$in.0 != null} | into record
  } else {
    null
  }
}

def graph-entry [] {
  let src = $in.src
  let target = $in.target
  $"\"($src)\" -> \"($target)\";"
}

def to-svg [
  --ignore: list<string>
] {
  let nodes = $in

  # Get all inputs in the form src -> (name, target)
  let flattened = $nodes | update cells {|it|
    if ("inputs" in $it) {
      $it.inputs | update cells {|it| $it | get-target} | transpose k v
    } else {
      null
    }
  } | transpose k v | flatten

  # We only care about the target and don't care about nulls
  let nodes = $flattened | where {$in.v != null and $in.v.v != null} | each {|it| {
    src: $it.k,
    target: $it.v.v
  }} | where { not ($in.target in $ignore)}

  # Render the whole thing via graphviz
  let body = $nodes | each {graph-entry} | str join "\n"

  # TODO: Standardise all graphviz formatting. Maybe override nixpkgs with a wrapped
  # version that applies the standard settings, at least when building docs
  let src = $"
    digraph {
      rankdir=LR;
      bgcolor=transparent;
      fillcolor=gray;
      node [style=filled];
      edge [color=white];
      ($body)
    }
  "

  $src | dot -Tsvg
}

# Display a flake's lock file as a tree of inputs
# to their dependencies
# Intended for helping to understand the structure of a flake,
# how its inputs are related, and what the final dependency tree
# looks like
export def main [
  file: string = "flake.lock"
  # Whether to render the tree as an SVG on stdout
  --svg
  # If rendering as SVG, ignore these inputs. Useful for stripping out
  # standard inputs like nixpkgs and systems
  # FIXME: This doesn't work when calling from the CLI, only for Nu functions
  # --svg-ignore: list<string> = []
] {
  let svg_ignore = [nixpkgs systems flake-utils]
  let nodes = open $file | from json | get nodes

  if $svg {
    $nodes | to-svg --ignore $svg_ignore
  } else {
    $nodes.root | resolve-deps $nodes
  }
}
