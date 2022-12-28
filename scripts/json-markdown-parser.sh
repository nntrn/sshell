#!/usr/bin/env bash

set -e

#   Combine and convert markdown files into one json file
#   Markdown files need to

OUTDIR=$(mktemp -d)
INPUT_FILE=$OUTDIR/input.txt
OUTPUT_FILE=$OUTDIR/data.json

usage() {
  echo "
Usage:
  $0 [options...]

Options:
  -c, --content-dir DIR       Directory to read markdown entries
  -w, --write-to FILE         File path to write output to
  -s, --stdin                 Read from stdin

Examples:

  Read markdown entries from directory
    $0 -c ./content

  Write output to data.json
    $0 -w data.json

  Read from stdin
    cat content/*.md | $0 -s
"
  exit 1
}

for i in "$@"; do
  case $i in
  -c | --content-dir)
    [[ -d $2 ]] && find $2 -type f -name "*.md" -exec cat {} \; >$INPUT_FILE
    shift 2
    ;;
  -s | --stdin)
    cat >$INPUT_FILE
    shift
    ;;
  -w | --write-to)
    mkdir -p "$(dirname $2)"
    OUTPUT_FILE=$2
    shift 2
    ;;
  -h | --help)
    usage
    ;;
  esac
done

if [[ -s $INPUT_FILE ]]; then

  cat $INPUT_FILE | jq -R -r -s '
def md:
  split("---")
  | ((.[1] | split("\n") | map(capture("(?<key>[a-z]+): (?<value>.*)")) |from_entries )
   + (.[2:] | join("\n") | split("\n## ") | map(capture("(?<key>[A-Z][a-z]+)\n\n(?<value>.*)\n"; "m"))
  | map({key: (.key|ascii_downcase), value: (.value|split("\n")|map(select(contains("```")|not))) })
  | from_entries));

[splits("\n<!-- end -->\n";"p")]
  | map(md?)
  | map(to_entries|map({key, value: (.value|tonumber? // (if .=="" then "(blank)" else . end))})
  | from_entries)
' | jq --sort-keys 'map(. + {tags: ((.tags//"[]")|fromjson)  }) | sort_by(.id) | reverse' |
    jq 'map({id,title,created,modified,language}+.)' | tee $OUTPUT_FILE

else
  echo "An error occured!"
  exit 1
fi

trap 'rm -rf -- "$OUTDIR"' EXIT
