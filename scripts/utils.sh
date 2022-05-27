#!/usr/bin/env bash

get_last_id() {
  cat $1 | jq -r '.[]| .id' | sort -n | tail -n 1
}

get_last_modified() {
  cat $1 | jq -r '.[]|.modified' | sort -d | tail -n 1
}

bye() {
  echo "ERROR: $* Aborting..."
  exit 1
}

git_commit_create() {
  while read -r line; do
    git add $line
    git commit -m "Create $line"
  done < <(git ls-files --other $1)
}

git_commit_update() {
  while read -r line; do
    git add $line
    git commit -m "Update $line"
  done < <(git ls-files --modified $1)
}
