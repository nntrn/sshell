#!/usr/bin/env bash

cd "$(realpath ${0%/*})" || exit

DIR=$(git rev-parse --show-toplevel)
REMOTE_URL=$(git config --get-regexp '^remote.*url' | awk '{print $2}' | head -n 1)
REPO=$(basename ${REMOTE_URL%.git})
BRANCH=gh-pages
TMPDIR=$(mktemp -d)

(cd $TMPDIR && git clone -b $BRANCH $REMOTE_URL $REPO &>/dev/null && cd $REPO) || exit

rm $TMPDIR/$REPO/*

cp -r $DIR/public/* $TMPDIR/$REPO/

git add -A .
git commit -m "Update static files"
git push
