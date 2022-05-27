#!/usr/bin/env bash

set -e

DIR="$(cd "$(dirname "$0")/.." && pwd)"
CURRENT_BRANCH=$(git branch --show-current)
REMOTE_URL=$(git config --get remote.origin.url)
REMOTE_BRANCHES=$(git remote show origin | sed -n '/Remote branches/,/Local/p' | grep -v ':' | awk '{print $1}')
GIT_BRANCH=data
TMPDIR=$(mktemp -d)
TMPFILE=$TMPDIR/snippets-new.json
TMPREADME=$TMPDIR/readme.md
TMPMODFILE=$TMPDIR/modified.txt
TODAY=$(date +%F)
trap 'rm -rf -- "$TMPDIR"' EXIT

STDOUT="$@"

source $DIR/scripts/utils.sh

if [[ -t 1 || $# -eq 0 || -f $1 ]]; then
  STDOUT=$(cat $1)
  echo "$STDOUT" | python3 -m json.tool >$TMPFILE
else
  bye "An error occured reading stdin"
fi

cd $TMPDIR

git init
git remote add origin $REMOTE_URL

if [[ $(echo "$REMOTE_BRANCHES" | grep $GIT_BRANCH) ]]; then
  git fetch origin $GIT_BRANCH
  git checkout $GIT_BRANCH
else
  git checkout -b $GIT_BRANCH
fi

[[ ! -d data ]] && mkdir data

if [[ -f snippets.json ]]; then
  export last_modified=$(cat snippets.json | get_last_modified)
  export last_id=$(cat snippets.json | get_last_id)

  cat $TMPFILE | jq -c "(.[]|select(.modified > \"$last_modified\"))" >$TMPMODFILE

  if [[ -s $TMPMODFILE ]]; then
    cat $TMPFILE >snippets.json
    cat $TMPFILE | jq -c -r '.[]| .language' | sort | uniq -c | sort -n -r -k1 >$TMPREADME
    languages=($(cat $TMPREADME | awk '{print $2}'))
    cat $TMPREADME | awk '{print "- [" $2 "](#" $2 ") (" $1 ")" }'

    while read -r line; do
      filename="data/$(echo "$line" | jq -r '.id')"
      echo "$line" | jq >$filename
    done <$TMPMODFILE

    for lang in "${languages[@]}"; do
      echo -e "\n## $lang\n" >>$TMPREADME
      cat $TMPFILE |
        jq -r ".[] | select(.language==\"$lang\")| \"- [\"+.id+\"](data/\"+.id+\"): \"+.title" >>$TMPREADME
    done

    sed -i '1s/^/# data /' $TMPREADME
    sed -i 's/  */ /g' $TMPREADME
  fi
fi

if [[ -z $(git status snippets.json | grep "nothing to commit") ]]; then
  git add snippets.json readme.md
  git add data
  git commit -m "Update data - $TODAY"
  git push origin $GIT_BRANCH
else
  echo "No changes"
fi

cd $HOME
[[ -d $TMPDIR ]] && rm -rf $TMPDIR
