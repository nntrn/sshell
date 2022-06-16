#!/usr/bin/env bash

set -e

STDOUT="$@"
DIR="$(cd "$(dirname "$0")/.." && pwd)" && cd "$DIR"

REMOTE_URL=$(git config --get remote.origin.url)
USER_EMAIL=$(git config --local --get user.email)
BRANCH=data

TMPDIR=$(mktemp -d)
TMPFILE=$TMPDIR/snippets-new.json
TMPREADME=$TMPDIR/sshell/readme.md
TMPMODFILE=$TMPDIR/modified.txt

trap 'rm -rf -- "$TMPDIR"' EXIT
source $DIR/scripts/utils.sh

if [[ -t 1 || $# -eq 0 || -f $1 ]]; then
  STDOUT=$(cat $1)
  echo "$STDOUT" | tr -d '\r' | tr -d '\0' >$TMPFILE
else
  bye "An error occured reading stdin"
fi

cd $TMPDIR

git clone -b $BRANCH $REMOTE_URL && cd "$(basename "$_" .git)"
git config --local user.email $USER_EMAIL

cp snippets.json{,.bkp}

last_modified=$(get_last_modified <snippets.json)
cat $TMPFILE | jq -c "(.[]|select(.modified > \"$last_modified\"))" | tr -d '\r' >$TMPMODFILE
cat $TMPFILE | jq -c -r '.[]| .language' | sort | uniq -c | sort -n -r -k1 >$TMPREADME
cat $TMPFILE >snippets.json

languages=($(cat $TMPREADME | awk '{print $2}'))
gawk -i inplace '{print "- [" $2 "](#" $2 ") (" $1 ")" }' $TMPREADME

for lang in "${languages[@]}"; do
  {
    echo -e "\n## $lang\n"
    cat $TMPFILE | jq -r ".[] | select(.language==\"$lang\")| \"- [\"+.id+\"](data/\"+.id+\"): \"+.title"
    echo -e "\n[[Return to top]](#data)\n"
  } >>$TMPREADME
done

if [[ -s $TMPMODFILE ]]; then
  [[ ! -d data ]] && mkdir data
  while read -r line; do
    filename="data/$(echo "$line" | jq -r '.id')"
    echo "Updating $filename"
    echo "$line" | jq >$filename
  done <$TMPMODFILE

  echo "Done Updating"
fi

sed -i '1s/^/# data\n\n/' $TMPREADME
sed -i 's/  */ /g' $TMPREADME

cat snippets.json.bkp | tr -d '\r' | jq -r '.[]|.id' >$TMPDIR/bkp_ids.txt
cat snippets.json | jq -r '.[]|.id' >$TMPDIR/ids.txt
grep -vFxf $TMPDIR/ids.txt $TMPDIR/bkp_ids.txt || true >$TMPDIR/deleted_ids.txt

if [[ -s $TMPDIR/deleted_ids.txt ]]; then
  echo "Deleting..."
  while read -r del_id; do
    echo "Deleting $del_id"
    rm $TMPDIR/sshell/data/$del_id
  done <$TMPDIR/deleted_ids.txt
fi

if ! grep -q "nothing to commit" <(git status snippets.json readme.md data); then
  git add snippets.json readme.md data
  git commit -m "Update data"
  git push origin $BRANCH
else
  echo "No changes"
fi
