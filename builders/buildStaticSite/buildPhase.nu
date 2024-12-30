#!/usr/bin/env nu

def main [
    src: string
    out: string
    # These aren't available in the build env, so we'll need to pass them in on the Nix side
    --buildPhp: string
] {
    print $src
    mkdir $out

    cd $src
    # Nu loves to work with structured data, but can be a bit verbose for procedural tasks
    # like this one.
    ls --all **/* | each {|file|
        if ('.build-only' in $file.name) {
            return
        }

        let info = $file.name | path parse

        # Eventual output directory
        let out_dir = $out | path join $info.parent
        mkdir $out_dir

        let file_as_html = $"($out_dir)/($info.stem).html"
        match $info.extension {
            # Transform PHP to HTML
            "php" => {
                php -f $buildPhp $file.name | save $file_as_html
            }
            # Copy all other files as-is
            _ => {
                cp $file.name $out_dir
            }
        }
    }
}
