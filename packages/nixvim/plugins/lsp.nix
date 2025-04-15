{pkgs, ...}: {
  plugins.treesitter = {
    enable = true;

    settings = {
      highlight.enable = true;
    };

    # Default is to install _everything_, which is excessive for my needs
    # This subset contains all of the launguages used in this repo, and can
    # be extended as needed
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      bash
      css
      dot
      gitignore
      html
      ini
      json
      latex
      lua
      markdown
      nix
      nu
      php
      python
      rust
      toml
      typescript
      xml
      yaml
    ];
  };
}
