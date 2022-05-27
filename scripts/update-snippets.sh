#!/usr/bin/env bash

set -e

STDOUT="$@"
DIR="$(cd "$(dirname "$0")/.." && pwd)" && cd "$DIR"
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

export last_modified=$(cat snippets.json | get_last_modified)
export last_id=$(cat snippets.json | get_last_id)

cat $TMPFILE | jq -c "(.[]|select(.modified > \"$last_modified\"))" >$TMPMODFILE
cat $TMPFILE | jq -c -r '.[]| .language' | sort | uniq -c | sort -n -r -k1 >$TMPREADME
cat $TMPFILE >snippets.json
languages=($(cat $TMPREADME | awk '{print $2}'))
gawk -i inplace '{print "- [" $2 "](#" $2 ") (" $1 ")" }' $TMPREADME

for lang in "${languages[@]}"; do
  echo -e "\n## $lang\n" >>$TMPREADME
  cat $TMPFILE |
    jq -r ".[] | select(.language==\"$lang\")| \"- [\"+.id+\"](data/\"+.id+\"): \"+.title" >>$TMPREADME
  echo -e "\n[[Return to top]](#data)\n" >>$TMPREADME
done

if [[ -s $TMPMODFILE ]]; then
  while read -r line; do
    filename="data/$(echo "$line" | jq -r '.id')"
    echo "$line" | jq >$filename
  done <$TMPMODFILE
fi

sed -i '1s/^/# data\n\n /' $TMPREADME
sed -i 's/  */ /g' $TMPREADME

if [[ -z $(git status snippets.json readme.md data | grep "nothing to commit") ]]; then
  git add snippets.json readme.md data
  git commit -m "Update data - $TODAY"
  git push origin $GIT_BRANCH
else
  echo "No changes"
fi

cd $HOME
[[ -d $TMPDIR ]] && rm -rf $TMPDIR
