#!/usr/bin/env bash

cd $(realpath ${0%/*})

PARENTDIR="$(git rev-parse --show-toplevel)"
REMOTE_URL=$(git config --get-regexp '^remote.*url' | awk '{print $2}' | head -n 1)
BRANCH=data
REPO=$REPO

TMPDIR=$(mktemp -d)
cat $1 | tr -d '\r' >$TMPDIR/data.json
cat $TMPDIR/data.json | jq -rc '.[]' >$TMPDIR/data.txt

cd $TMPDIR
git clone -b $BRANCH $REMOTE_URL &>/dev/null
cd $REPO

while read -r line; do
  SNIPPET_ID=$(echo "$line" | jq -r '.id')
  echo "$line" | jq >data/$SNIPPET_ID
done <$TMPDIR/data.txt

cat $TMPDIR/data.json >$TMPDIR/$REPO/data.json

git config --local --list
git add -A .
git commit -m "Commit changes"
git push

echo $TMPDIR
