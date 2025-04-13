# Style Guide

- [Style Guide](#style-guide)
  - [General Rules](#general-rules)
  - [Code](#code)
    - [Error Handling (Nix)](#error-handling-nix)
    - [Code Style](#code-style)

Since I plan this to be a long-term project and always work-in-progress, I want
to keep things clean and easy to work with. Therefore, I have created this set
of guidelines for code and documentation.

## Code

The following practices are recommended when developing this repository:

### Error Handling (Nix)

Use the `config.assertions` list to check for invalid options or combinations of
options, such as
[installing VS Code on a headless server](../modules/home/editor/vscode/default.nix).

This gives a nicely formatted error message and collects all errors rather than
stopping at the first one.

### Code Style

The most important rule is: **keep it simple**. If you can't understand what a
piece of code does after a few seconds, it's too complex. In addition:

Run `nix fmt` before committing to ensure consistent code style. This is also
configured to run a set of static analysers on their strictest settings. If a
static analyser says something is wrong, it's probably wrong.

An apostrophe (`'`) after a variable name is used to indicate that it is an
overridden package (See the
[reddit question](https://www.reddit.com/r/NixOS/comments/ttaw5u/what_is_the_purpose_of_single_quotes_after/),
TL;DR: it's from the prime symbol meaning a derivative in mathematics). This is
not strictly required, but is included for consistency with Nixpkgs.
