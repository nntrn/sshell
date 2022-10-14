#!/usr/bin/env bash

cd "$(realpath ${0%/*})" || exit 1

DIR=$(git rev-parse --show-toplevel)
REMOTE_URL=$(git config --get-regexp '^remote.*url' | awk '{print $2}' | head -n 1)
BRANCH=gh-pages
REPO=$(basename $(echo ${REMOTE_URL#*/} .git))

IFS=$'\n'

PUBLIC_FILES=($(git ls-files --other --exclude-standard --full-name public))

if [[ ${#PUBLIC_FILES[@]} -gt 0 ]]; then
  echo hi

else
  echo "No changes to public"
  exit 0
fi

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

cp $TMPDIR/data.json $TMPDIR/$REPO

jq -r 'sort_by(.modified)|.[-1]|{"last_modified":.modified}' $TMPDIR/data.json >$TMPDIR/$REPO/meta.json

git config --local --list
git add -A .
git commit -m "Commit changes"
git push

echo $TMPDIR
