#!/usr/bin/env bash

DIR="$(cd "$(dirname "$0")/.." && pwd)"
STDOUT="$@"

if [[ -t 1 || $# -eq 0 ]]; then
  STDOUT=$(cat)
fi

if [[ -z "$STDOUT" ]]; then
  echo "An error occured reading.. Aborting"
  exit 1
fi

TMPDIR=$(mktemp -d)
TMPFILE=$(mktemp)

echo "$STDOUT" >$TMPFILE

CURRENT_BRANCH=$(git branch --show-current)
REMOTE_URL=$(git config --get remote.origin.url)
GIT_BRANCH=data

cd $TMPDIR

git init
git remote add origin $REMOTE_URL
git fetch -a

if [[ $(git branch -a | grep $GIT_BRANCH) ]]; then
  git checkout data
else
  git checkout -b data
fi

cat $TMPFILE >snippets.json

if [[ -z $(git status --ignore-submodules=dirty | grep "nothing to commit, working directory clean") ]]; then
  git add snippets.json
  git commit -m "Update changes"
  git push origin $GIT_BRANCH
else
  echo "No changes"
fi

[[ -d "$TMPDIR" ]] && rm -rf "$TMPDIR"
[[ -f "$TMPFILE" ]] && rm "$TMPFILE"
