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
          config = runLua "require('lualine').setup()";
        }
      ];
    };
  };
}
