#!/usr/bin/env bash

set -e

cd "$(realpath ${0%/*})"

REMOTE_URL=$(git config --get-regexp '^remote.*url' | awk '{print $2}' | head -n 1)
REPO=$(basename ${REMOTE_URL%.git})
BRANCH=data
TMPDIR=$(mktemp -d)

[[ -f $1 && $1 != "all" ]] && DATA_FILE=$1

cat $DATA_FILE | tr -d '\r' >$TMPDIR/data.json
cat $TMPDIR/data.json | jq -rc '.[]' >$TMPDIR/data.txt

cd $TMPDIR
git clone -b $BRANCH $REMOTE_URL $REPO &>/dev/null
cd $REPO

if [[ $1 == all ]]; then
  rm -rf $TMPDIR/$REPO/data
fi

mkdir -p $TMPDIR/$REPO/data

while read -r line; do
  SNIPPET_ID=$(echo "$line" | jq -r '.id')
  echo "$line" | jq >$TMPDIR/$REPO/data/$SNIPPET_ID
done <$TMPDIR/data.txt

cat $TMPDIR/$REPO/data/* | jq -s '.|sort_by(.id)|reverse' >$TMPDIR/$REPO/data.json

echo "# data" >$TMPDIR/$REPO/readme.md
cat $TMPDIR/$REPO/data.json | jq -r 'group_by(.language)|map({"\(.[0].language)": (.)}) |add|to_entries|.[]| ["\n## " +.key+"\n","- "+(.value|.[]|"[\(.id)](data/\(.id)): \(.title)")]|join("\n")' >>$TMPDIR/$REPO/readme.md

jq -r 'sort_by(.modified)|.[-1]|{"last_modified":.modified}' $TMPDIR/$REPO/data.json >$TMPDIR/$REPO/meta.json

git add -A .
git commit -m "Commit changes"
git push

echo $TMPDIR
