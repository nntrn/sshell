#!/usr/bin/env bash

set -e
cd "$(realpath ${0%/*})"

DIR=$(git rev-parse --show-toplevel)
REMOTE_URL=$(git config --get-regexp '^remote.*url' | awk '{print $2}' | head -n 1)
REPO=$(basename ${REMOTE_URL%.git})
BRANCH=gh-pages
TMPDIR=$(mktemp -d)
IFS=$'\n'

cd $DIR

if git ls-files --exclude-standard --full-name --modified --deleted --other public; then
  git add public
  git commit -m "Update web files before pushing to gh-pages"
  git push
fi

(cd $TMPDIR && git clone -b $BRANCH $REMOTE_URL $REPO &>/dev/null && cd $REPO)

rm $TMPDIR/$REPO/*

cp -r $DIR/public/* $TMPDIR/$REPO/

git add -A .
git commit -m "Update static files"
git push
