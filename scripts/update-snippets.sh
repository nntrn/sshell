#!/usr/bin/env bash

set -e

STDOUT="$@"
DIR="$(cd "$(dirname "$0")/.." && pwd)" && cd "$DIR"
REMOTE_URL=$(git config --get remote.origin.url)
GIT_BRANCH=data
TMPDIR=$(mktemp -d)
TMPFILE=$TMPDIR/snippets-new.json
TMPREADME=readme.md
TMPMODFILE=$TMPDIR/modified.txt

trap 'rm -rf -- "$TMPDIR"' EXIT
source $DIR/scripts/utils.sh

if [[ -t 1 || $# -eq 0 || -f $1 ]]; then
  STDOUT=$(cat $1)
  echo "$STDOUT" >$TMPFILE
else
  bye "An error occured reading stdin"
fi

cd $TMPDIR

git clone -b $GIT_BRANCH $REMOTE_URL && cd "$(basename "$_" .git)"
git config --local user.email 17685332+nntrn@users.noreply.github.com

cp snippets.json{,.bkp}
last_modified=$(get_last_modified <snippets.json)
cat $TMPFILE | jq -c "(.[]|select(.modified > \"$last_modified\"))" >$TMPMODFILE
cat $TMPFILE | jq -c -r '.[]| .language' | sort | uniq -c | sort -n -r -k1 >$TMPREADME
cat $TMPFILE | tr -d '\r' | tr -d '\0' >snippets.json
languages=($(cat $TMPREADME | awk '{print $2}'))
gawk -i inplace '{print "- [" $2 "](#" $2 ") (" $1 ")" }' $TMPREADME

for lang in "${languages[@]}"; do
  {
    echo "## $lang"
    jq -r ".[] | select(.language==\"$lang\")| \"- [\"+.id+\"](data/\"+.id+\"): \"+.title" <$TMPFILE
    echo
    echo "[[Return to top]](#data)"
    echo
  } >>$TMPREADME
done

if [[ -s $TMPMODFILE ]]; then
  [[ ! -d data ]] && mkdir data
  while read -r line; do
    filename="data/$(echo "$line" | jq -r '.id')"
    echo "$line" | jq >$filename
  done <$TMPMODFILE
fi

sed -i '1s/^/# data\n\n /' $TMPREADME
sed -i 's/  */ /g' $TMPREADME

SNIPPETS_BKP_ID=$(jq -rc '.[]|.id' <snippets.json.bkp)
SNIPPETS_ID=$(jq -rc '.[]|.id' <snippets.json)
DELETED_IDS=($(grep -vFxf <(echo "$SNIPPETS_ID") <(echo "$SNIPPETS_BKP_ID") | sed 's,^,data/,g'))

[[ ${#DELETED_IDS[@]} -gt 0 ]] && rm "${DELETED_IDS[@]}"

if ! grep -q "nothing to commit" <(git status snippets.json readme.md data); then
  git add snippets.json readme.md data
  git commit -m "Update data"
  git push origin $GIT_BRANCH
else
  echo "No changes"
fi

cd $HOME
[[ -d $TMPDIR ]] && rm -rf $TMPDIR
