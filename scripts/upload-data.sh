#!/usr/bin/env bash

set -e

REMOTE_URL=https://github.com/nntrn/sshell.git
REPO=$(basename $REMOTE_URL .git)
BRANCH=data
TMPDIR=$(mktemp -d)

cat $1 | tr -d '\r' >$TMPDIR/data.json

cd $TMPDIR

if [[ -s $TMPDIR/data.json ]]; then
  git clone -b $BRANCH $REMOTE_URL
  cd $REPO

  jq 'sort_by(.id)|reverse' $TMPDIR/data.json >data.json

  {
    echo "<h1 id=\"top\">${REPO}/data</h1>"
    echo ""
    echo '```sh'
    echo "git clone -b $BRANCH $REMOTE_URL"
    echo "cd $REPO"
    echo '```'
    echo ""
  } >readme.md

  jq -r '[(map(.language) | unique | map("* [\(.)](#\(.))")),
  (group_by(.language) | map(["","## \(.[0].language)", "",
  map(["### \(.title)","","```\(.language)",(.code|join("\n")),"```",""]),
  "[Top](#top)"])) ] | flatten(4) | join("\n")' data.json >>readme.md

  git config --local user.email 17685332+nntrn@users.noreply.github.com
  git add data.json readme.md
  git commit -m "Commit changes"
  git push

fi

trap 'rm -rf -- "$TMPDIR"' EXIT
