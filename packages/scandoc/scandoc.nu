#!/usr/bin/env nu

let PAPERLESS_API_KEY = open $env.PAPERLESS_API_KEY_FILE
let PAPERLESS_URL = $env.PAPERLESS_URL
# This is sourced from the host configuration rather than dynamically
# as scanimage -L is slow
let SCANNER = $env.SCANNER

def scan [
  out: path
] {
  (scanimage --format jpeg --mode Color
    --device $SCANNER
    --resolution 300 --output-file $out err> /dev/null
  )
}

def post_document [
  file: path
  name: string
] {
  (http post $"($PAPERLESS_URL)/api/documents/post_document/"
  --content-type "multipart/form-data" {
    document: (open --raw $file)
    title: $name
  } --headers {
    Authorization: $"Token ($PAPERLESS_API_KEY)"
  })
}

# Scan a multi-page document into a single PDF
# Insert first page before starting, then follow prompts.
# Final document will be uploaded to paperless
def main [
  pages: int
  name: string
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

  let output = mktemp --suffix .pdf
  magick ...(ls $tmpdir | get name) $output
  post_document $output $name
  rm --recursive $tmpdir
}
