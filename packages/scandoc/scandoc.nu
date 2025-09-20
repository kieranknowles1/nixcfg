#!/usr/bin/env nu

let PAPERLESS_API_KEY = open $env.PAPERLESS_API_KEY_FILE
let PAPERLESS_URL = $env.PAPERLESS_URL

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
