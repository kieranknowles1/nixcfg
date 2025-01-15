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
    $node.inputs | transpose k v | each {|it|
      let target = $it.v | get-target
      [$target ($target | resolve-dep $nodes)]
    } | where {$in.0 != null} | into record
  } else {
    null
  }

}

# Display a flake's lock file as a tree of inputs
# to their dependencies
def main [
  file: string = "flake.lock"
] {
  let nodes = open $file | from json | get nodes

  $nodes.root | resolve-deps $nodes
}
