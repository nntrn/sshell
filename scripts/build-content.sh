#!/usr/bin/env bash

set -e

OUTPUT_DIR=content
TMPSCRIPT=$(mktemp)
REMOTE_DATA=https://raw.githubusercontent.com/nntrn/sshell/data/data.json

usage() {
  echo "
Usage:
  $0 [options...]

Options:
  -o, --output DIRECTORY      Output for markdown files (Default: content)
  -i, --input FILE            File path of data.json
  -s, --stdin                 Read from stdin
  -r, --remote                Download and use remote input file

Examples:

  Create entries from remote data
    $0 -r

  Write entries in /tmp/content
    $0 -o /tmp/content

  Create entries from local data
    $0 -i data.json

  Read data from stdin
    cat data.json | $0 -s
"
  exit 1
}

use_remote_data() {
  INPUT_FILE=$(mktemp)
  curl -s -o $INPUT_FILE $REMOTE_DATA
}

for i in "$@"; do
  case $i in
  -o | --output)
    OUTPUT_DIR=$2
    shift 2
    ;;
  -i | --input)
    INPUT_FILE=$2
    shift 2
    ;;
  -s | --stdin)
    INPUT_FILE=$(mktemp)
    cat >$INPUT_FILE
    shift
    ;;
  -r | --remote)
    IS_REMOTE=1
    shift
    ;;
  -h | --help)
    usage
    ;;
  esac
done

[[ -f $1 ]] && INPUT_FILE=$1

if [[ -n $IS_REMOTE ]] || [[ ! -f $INPUT_FILE ]]; then
  echo "Getting data from remote: REMOTE_DATA"
  use_remote_data
fi

cat $INPUT_FILE | jq -r --arg output_dir "$OUTPUT_DIR" 'map(. + { markdown: ([
  "---",
  "id: \(.id)",
  "title: \(.title)",
  "language: \(.language)",
  "created: \(.created)",
  "modified: \(.modified)",
  (if (has("tags") and (.tags|length) > 0 ) then "tags: \(.tags|tostring)" else null end),
  (if has("url") then "url: \(.url)" else null end),
  "---",
  (if has("description") then "\n## Description\n\n\(.description|join("\n"))" else null end),
  (if has("code") then "\n## Code\n\n```\(.language)\n\(.code|join("\n"))\n```" else null end),
  (if has("example") then "\n## Example\n\n```\n\(.example|join("\n"))\n```" else null end),
  (if has("output") then "\n## Output\n\n```\n\(.output|join("\n"))\n```" else null end),
  "\n<!-- end -->",
  ""
  ] | map(select(.)) | join("\n")| split("\n") )
})
|.[]|@sh "echo \(.markdown | join("\n") ) >" + ([.id,".md","\n"]|join(""))
' >>$TMPSCRIPT

mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR
echo "Writing to $PWD"
source $TMPSCRIPT

trap 'rm -f -- "$TMPSCRIPT"' EXIT
