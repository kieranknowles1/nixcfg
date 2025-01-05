#!/usr/bin/env nu

# Extract the contents of an archive file to a directory, automatically detecting
# the format and extraction tool to use.
# Outputs to a directory with the same name as the input file, minus the extension.
# The following formats are supported:
# - zip
# - 7z (7zip)
# - rar (winrar)
def main [
    # The file to extract
    file: string
] {
    let path = $file | path parse
    let out_dir = $path.parent | path join $path.stem
    mkdir $out_dir

    let mime = xdg-mime query filetype $file

    match $mime {
        "application/zip" => {
            unzip $file -d $out_dir
        }
        "application/x-7z-compressed" => {
            7z x $file $"-o($out_dir)"
        }
        "application/vnd.rar" => {
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
