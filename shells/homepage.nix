{
  nodejs,
  rust,
  tmux,
  writeShellScriptBin,
}:
rust.overrideAttrs (oldAttrs: let
  nodeLaunch = writeShellScriptBin "node-launch" ''
    # Prepare type bindings
    cd $FLAKE/packages/homepage-back
    cargo test
    cd $FLAKE/packages/homepage-front
    rm -r src/bindings
    mv ../homepage-back/bindings src/bindings

    npm run dev
  '';

  rustLaunch = writeShellScriptBin "rust-launch" ''
    cd $FLAKE/packages/homepage-back

    export HOMEPAGE_ENABLE_SYSINFO=true
    cargo run
  '';

  devBoth = writeShellScriptBin "launch-all" ''
    tmux new-session -d -s homepage rust-launch
    tmux split-window -h node-launch

    tmux attach-session -t homepage
  '';
in {
  name = "homepage";

  nativeBuildInputs =
    oldAttrs.nativeBuildInputs
    ++ [
      nodejs
      tmux
      nodeLaunch
      rustLaunch
      devBoth
    ];

  shellHook = ''
    launch-all
  '';
})
