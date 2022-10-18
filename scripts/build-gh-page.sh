#!/usr/bin/env bash

set -e
cd "$(realpath ${0%/*})"

DIR=$(git rev-parse --show-toplevel)
REMOTE_URL=$(git config --get-regexp '^remote.*url' | awk '{print $2}' | head -n 1)
REPO=$(basename ${REMOTE_URL%.git})
BRANCH=gh-pages
TMPDIR=$(mktemp -d)

echo "$TMPDIR"
echo "$DIR"
echo "$REPO"
echo "$REMOTE_URL"

if [[ $(git -C "$DIR" ls-files --modified public) ]]; then
  git -C "$DIR" add public
  git -C "$DIR" commit -m "Update web files before pushing to gh-pages"
  git -C "$DIR" push
fi

cd $TMPDIR
git clone -b $BRANCH $REMOTE_URL $REPO
cd $REPO

cp $DIR/public/* .

git add .
git commit -m "Update static files"
git push
