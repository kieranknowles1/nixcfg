# Style Guide

Guidelines for code and documentation.

- [Style Guide](#style-guide)
  - [General Rules](#general-rules)
  - [Documentation](#documentation)
    - [Tables of Contents](#tables-of-contents)
    - [Referencing Other Files](#referencing-other-files)
  - [Code](#code)
    - [Code Style](#code-style)
      - [Nix Specific](#nix-specific)
    - [Error Handling (Nix)](#error-handling-nix)

Since I plan this to be a long-term project and always work-in-progress, I want
to keep things clean and easy to work with. Therefore, I have created this set
of guidelines for code and documentation.

## General Rules

- Commit messages SHOULD be written in the format `component: description`,
  additional information can be provided in the commit message body.

## Documentation

Requirement specifications MUST use the
[MoSCoW](https://en.wikipedia.org/wiki/MoSCoW_method) method.

Application-specific terms SHOULD be displayed in **bold**, and given a
definition the first time they are used. Future references only require being
bold. For example, in [Activate Mutable Plan](../plan/activate-mutable.md):

> ... this script takes the **deployed file** as input, and outputs a file,
> **repo file**, that is suitable for version control...
>
> **Repo file** is converted to **deployed file** during the NixOS build
> process.

Keep it concise. Don't write a full paragraph when a single sentence will do.

When possible, use [generated docs](./modules/docs.md) as specified in the
linked page.

### Tables of Contents

Tables of contents SHOULD be included in Markdown files with more than a few
sections (no hard threshold). These can be generated with VS Code's
[Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
extension.

<!-- TODO: Check these are up to date and/or generate them automatically -->

### Referencing Other Files

Markdown files MUST use Markdown links. All other contexts MUST use the VS Code
[Comment Links](https://marketplace.visualstudio.com/items?itemName=Isotechnics.commentlinks)
extension format. That is: `[[<path_to_file>]]` where `<path_to_file>` begins
with either `./`, signifying a relative path, or `@`, for paths relative to the
root of the repository.

## Code

The following practices are recommended when developing this repository:

### Code Style

The most important rule is: **keep it simple**. If you can't understand what a
piece of code does after a few seconds, it's too complex. In addition:

Run `nix fmt` before committing to ensure consistent code style. This is also
configured to run a set of static analysers on their strictest settings. If a
static analyser says something is wrong, it's probably wrong.

#### Nix Specific

An apostrophe (`'`) after a variable name is used to indicate that it is an
overridden package (See the
[reddit question](https://www.reddit.com/r/NixOS/comments/ttaw5u/what_is_the_purpose_of_single_quotes_after/),
TL;DR: it's from the prime symbol meaning a derivative in mathematics). This is
not strictly required, but is included for consistency with Nixpkgs.

Avoid using `${self}` without good reason, as it makes the derivation depend on
the entire flake, and therefore be rebuilt whenever anything changes rather than
only the files it depends on.

### Error Handling (Nix)

Use the `config.assertions` list to check for invalid options or combinations of
options, such as
[installing VS Code on a headless server](../../modules/home/editor/vscode/default.nix).

This gives a nicely formatted error message and collects all errors rather than
stopping at the first one.
