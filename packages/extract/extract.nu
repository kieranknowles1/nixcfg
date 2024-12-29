#!/usr/bin/env nu

# Extract the contents of an archive file to a directory, automatically detecting
# the format and extraction tool to use.
# Outputs to a directory with the same name as the input file, minus the extension.
def main [
    # The file to extract
    file: string
] {
    let path = $file | path parse
    let out_dir = $"($path.parent)/($path.stem)"
    mkdir $out_dir

    match $path.extension {
        "zip" => {
            unzip $file -d $out_dir
        }
        "7z" => {
            7z x $file $"-o($out_dir)"
        }
        "rar" => {
            # TODO: How to specify the output directory?
            unrar x $file
        }
        _ => {
            error make {
                msg: "Unsupported archive format"
                label: {
                    text: "unknown extension"
                    span: (metadata $file).span
                }
            }
        }
    }
}
