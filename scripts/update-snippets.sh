#!/usr/bin/env bash

set -e

DIR="$(cd "$(dirname "$0")/.." && pwd)"
CURRENT_BRANCH=$(git branch --show-current)
REMOTE_URL=$(git config --get remote.origin.url)
GIT_BRANCH=data

STDOUT="$@"

if [[ -t 1 || $# -eq 0 ]]; then
  STDOUT=$(cat)
fi

if [[ $# -eq 1 && -f $1 ]]; then
  STDOUT=$(cat $1)
fi

if [[ -z "$STDOUT" ]]; then
  echo "An error occured reading.. Aborting"
  exit 1
fi

TMPDIR=$(mktemp -d)
TMPFILE=$(mktemp)

echo "$STDOUT" | jq >$TMPFILE

cd $TMPDIR

git init
git remote add origin $REMOTE_URL

REMOTEBRANCHES=$(git remote show origin | sed -n '/Remote branches/,/Local/p' | grep -v ':' | awk '{print $1}')

if [[ $(echo "$REMOTEBRANCHES" | grep $GIT_BRANCH) ]]; then
  git fetch origin $GIT_BRANCH
  git checkout $GIT_BRANCH
else
  git checkout -b $GIT_BRANCH
fi

cat $TMPFILE | jq >snippets.json

if [[ -z $(git status --ignore-submodules=dirty | grep "nothing to commit, working directory clean") ]]; then
  git add snippets.json
  git commit -m "Update changes"
  git push origin $GIT_BRANCH
else
  echo "No changes"
fi

[[ -f $TMPFILE ]] && rm -rf $TMPFILE
[[ -d $TMPDIR ]] && rm -rf $TMPDIR
