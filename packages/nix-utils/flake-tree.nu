#!/usr/bin/env nu

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
    # Recurse into children
    $node.inputs | transpose k v | each {|it|
      let target = $it.v | get-target
      [$target ($target | resolve-dep $nodes)]
    } | where {$in.1 != null} | into record
  } else {
    {} # Bottom of the tree
  }
}

def graph-entry [] {
  let src = $in.src
  let target = $in.target
  $"\"($src)\" -> \"($target)\";"
}

def to-dot [] {
  let include = $in | columns

  # Get all inputs in the form input -> [depends-on]
  let deps = $in | update cells {|it|
    if ("inputs" in $it) {
      $it.inputs | values | each {get-target} | where {$in in $include}
    } else {
      []
    }
  # `update cells` returns a single-row table for record inputs, so transform
  # back to a record
  } | get 0


  # Transform inputs into a flat list of src -> target, where src is not unique
  let flattened = $deps | transpose src target | flatten
  $flattened

  let body = $flattened | each {graph-entry} | str join "\n"
  $"
    digraph {
      rankdir=LR;
      ($body)
    }
  "
}

# Display a flake's lock file as a tree of inputs
# to their dependencies
# Intended for helping to understand the structure of a flake,
# how its inputs are related, and what the final dependency tree
# looks like
export def main [
  file: string = "flake.lock"
  # Whether to render the tree as a graphviz dot file on stdout
  --dot
  # List of input names to ignore
  ...ignore: string
] {
  let nodes = open $file | from json | get nodes
  let filtered = $nodes | transpose k v | where {not ($in.k in $ignore)} | transpose --as-record --header-row

  if $dot {
    $filtered | to-dot
  } else {
    $filtered.root | resolve-deps $filtered
  }
}
