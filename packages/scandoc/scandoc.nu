#!/usr/bin/env nu

def scan [
  out: path
] {
  # TODO: Automatically detect device address, builtin camera is also detected,
  # but we don't want to use it.
  (scanimage --format jpeg --mode Color
    --device "escl:https://192.168.1.138:443"
    --resolution 300 --output-file $out err> /dev/null
  )
}

# Scan a multi-page document into a single PDF
# Insert first page before starting, then follow prompts.
def main [
  pages: int
  output: path
] {
  let tmpdir = mktemp --directory --tmpdir

  for i in 1..$pages {
    let filename = $"($tmpdir)/page-($i).jpg"
    scan $filename
    print $"Scanned page ($i) of ($pages)"
    if $i != $pages {
      print $"Insert page ($i + 1) into scanner, then press any key to continue"
      input --numchar 1
    }
  }

  # TODO: Automatically upload final PDF to paperless
  magick convert ...(ls $tmpdir | get name) $output
  rm --recursive $tmpdir
}
