#!/usr/bin/env bash

set -e

REMOTE_URL=https://github.com/nntrn/sshell.git
REPO=sshell
BRANCH=data
TMPDIR=$(mktemp -d)

trap 'rm -rf -- "$TMPDIR"' EXIT

[[ -f $1 ]] && DATA_FILE=$1

cat $DATA_FILE | tr -d '\r' >$TMPDIR/data.json

cd $TMPDIR
git clone -b $BRANCH $REMOTE_URL $REPO &>/dev/null
cd $REPO

if [[ -s $TMPDIR/data.json ]]; then
  jq 'sort_by(.id)|reverse' $TMPDIR/data.json >data.json
fi

{
  echo "# ${REPO}/data"
  echo ""
  echo '```sh'
  echo "git clone -b $BRANCH $REMOTE_URL"
  echo "cd $REPO"
  echo '```'
  echo ""
} >readme.md

jq -r 'group_by(.language)
| map({"\(.[0].language)": (.)})
| add | to_entries| .[]
| ["\n## " +.key+"\n","- "+(.value|.[]|"[\(.id)](https://nntrn.github.io/sshell/#\(.id)): \(.title)")]
| join("\n")' data.json >>readme.md

jq -rc '.[]
| [.id,(.modified|sub("T"; " "))]
| join(" ")' data.json >modified.txt

git config --local user.email 17685332+nntrn@users.noreply.github.com
git add data.json readme.md modified.txt
git commit -m "Commit changes"
git push
