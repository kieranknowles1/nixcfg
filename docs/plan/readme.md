# Planning

Planning documents for past, present, and future development transcribed from
paper notes when they are in a state that can be worked on and cleaned up.
Consider them rough drafts, they may be incomplete, inaccurate, or subject to
change.

- [Activate Mutable](./activate-mutable.md)
- [Nix Server](./nix-server.md)

## Workflow

Documents are transcribed by taking a photo of the paper notes, then copying the
detected text into a markdown file. Machine transcriptions are very low quality,
so need significant clean up which is done manually.

I prefer paper for initial drafts over digital, as it forces me to think more
about what I'm writing, rather than just dumping my thoughts onto the screen.
Once I'm satisfied with a draft, I'll type a refined version into this
directory, one file per project.

## Todo List

Miscelaneous tasks I want to complete in the future. Tracked here rather than in
issues so I can do all my work in one place.

If a task is cancelled, do not remove it from the list. Instead mark it with a
❎ and ~~strike through~~.

- ❎ ~~Automate updates of packages.~~ Not planned. I want to at least glance at
  the changes before applying them.
- [x] Preview changes before applying them.
      [https://www.youtube.com/watch?v=DnA4xNTrrqY](https://www.youtube.com/watch?v=DnA4xNTrrqY)
- [x] Generate documentation rather than doing it manually
  - [x] For functions
  - [x] For options
- [x] Set keyboard shortcuts
  - [x] `Alt+T` to open terminal
  - [x] `Ctrl+Shift+Escape` to open System Monitor
  - [x] `Ctrl+Alt+E` to open FSearch
  - [x] Some way to disable keyboard LEDs
- [x] Associate file types with programs
  - [x] PDFs with Firefox, overriding LibreOffice
  - [x] Skyrim and Fallout 4 saves with ReSaver (already defined mime type, just
        need to set the program)
- ❎ ~~Port my server to NixOS.~~ Putting this on hold for now as Raspberry Pi 5
  is currently unsupported.
  - [x] Build ISO
        [https://www.youtube.com/watch?v=-G8mN6HJSZE](https://www.youtube.com/watch?v=-G8mN6HJSZE)
  - [ ] Remove anything not needed for a server
  - [ ] Update `rebuild update` as discussed in [Nix Server](./nix-server.md)
- [ ] Allow home-manager to be used independently of NixOS
  - [ ] Minimise usage of `hostConfig`, then pass it in as an argument (overlays
        should help with this)
  - [ ] Put this on the server until we can run full NixOS on it
- [ ] Automate running checks on the repo. Do these in nix's `checkPhase`?
  - [x] Links in Markdown
  - [ ] Links in comments
        [extension](https://marketplace.visualstudio.com/items?itemName=Isotechnics.commentlinks)
- [ ] Pre-commit hooks
  - [ ] Check that `nix fmt` doesn't change anything
- [x] Convert to `flake-parts` for better modularity
  - [x] `flake.nix`
  - [x] Template
- [x] Get swap files working
- [ ] Port my Steam Deck to NixOS. Use
      [Jovian NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS)
- [ ] Configure RAG based on my notetaking workflow
      [Tutorial](https://www.youtube.com/watch?v=fFgyOucIFuk), the UI used here
      has too much overhead currently
- [x] Hotkeys for brightness. Either `Alt+Home/End` or media keys.
- [ ] Fix `nixd` in Zed
- [ ] Fix nerd fonts in Zed
- [ ] Tidy docs-generate, split into multiple files, one for defaults and
      another for generating HTML.
  - ❎ ~~Only rebuild changed generated docs, rather than all of them.~~ No
    longer needed after switch to mdbook, as it is much faster than Pandoc.
  - [x] Rewrite store paths for options to point to the repo instead
- [ ] Use a Nix cache to speed up builds on my laptop. Would ideally be able to
      push a fully NixOS image to the laptop, rather than building locally which
      pushes memory limits.
- [x] Don't use `${self}/path` pattern<br> this causes a rebuild every time
      anything in the repo changes, rather than just when the file/directory
      changes.
