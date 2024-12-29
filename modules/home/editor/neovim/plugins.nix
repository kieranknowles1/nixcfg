{pkgs, ...}: {
  config = {
    programs.neovim = {
      # Most plugins use Lua, disable unnecessary runtimes
      withNodeJs = false;
      withPython3 = false;
      withRuby = false;

      plugins = let
        runLua = lua: ''
          lua <<EOF
          ${lua}
          EOF
        '';
      in with pkgs.vimPlugins; [
        which-key-nvim
        nvim-web-devicons

        {
          plugin = lualine-nvim;
          # TODO: This is stored in a file sourced by ~/.config/nvim/init.lua
          # which means it won't be updated when using the nvimd helper.
          # Can we extend the helper to replace the current file with what would be generated?
          config = runLua "require('lualine').setup()";
        }
      ];
    };
  };
}
