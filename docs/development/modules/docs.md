# Documentation

Documentation should be generated wherever possible, as this makes them tightly
coupled to their code and more likely to be up-to-date.

For more general information, such as this document, Markdown in the `docs`
directory is used.

Graphs may be generated using `graphviz` and `dot`, these are automatically
converted to SVGs by buildStaticSite. While Mermaid is natively supported by
GitHub, it is much less effective at preventing overlap and therefore unsuitable
for my needs.

## The `docs-generate` Module

`docs-generate` provides an interface to generate pages for the manual as either
Markdown or HTML via mdbook. When building HTML, any Markdown files will be
converted and added to the book's table of contents. Any other files are copied
as-is and can be referenced later.

```nix
"file-a.md" = {
  description = "Some generated stuff";
  source = ./docs-generated/file-a.md;
  # Set to false if the file will be the same regardless of the host/user's
  # config. This determines which subsection it is placed under.
  dynamic = true;
};
```

## Module Structure

This module is split into three parts: `nixos`, `home-manager`, and `shared`

- `shared` defines Nix options and build outputs to be used elsewhere, it has no
  effect on its own.
- `nixos` gives a set of predefined pages describing the flake's outputs and
  options.
- `home-manager` allows per-user extension of `pages` while inheriting any
  defined on the host's side, as well as an option to install these in the
  checked out repository and as a command palette option.
