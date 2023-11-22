<h1 id="top">sshell/data</h1>

```sh
git clone -b data https://github.com/nntrn/sshell.git
cd sshell
```

* [bash](#bash)
* [cmd](#cmd)
* [config](#config)
* [javascript](#javascript)
* [nginx](#nginx)
* [plain](#plain)
* [powershell](#powershell)
* [python](#python)
* [sql](#sql)
* [vim](#vim)
* [yaml](#yaml)

## bash

### grep for ansible-vault files and unseal

```bash
echo 'abc123' >/path/to/vault-password.txt
export ANSIBLE_VAULT_PASSWORD_FILE=/path/to/vault-password.txt
VAULTFILES=($(grep -rl '$ANSIBLE_VAULT;' .))
for i in "${VAULTFILES[@]}"; do
  mkdir -p unsealed/${i%/*}
  echo $i
  ansible-vault view $i >unsealed/$i
done

```

### Create a data URL from a file

```bash
dataurl() {
  local mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}
```

### capture groups

```bash
TODAY=$(date +%F)
regex="([0-9]{4})-([0-9]{2})-([0-9]{2})"
if [[ $TODAY =~ $regex ]]; then
  year="${BASH_REMATCH[1]}"
  month="${BASH_REMATCH[2]}"
  day="${BASH_REMATCH[3]}"
  echo "$month $year"
fi
```

### node trigger diagnostic report

```bash
process.report.writeReport();
```

### prints free memory

```bash
available=$(awk '/^Cached/ { c=$2 } /^MemAvailable/ { a=$2 } END { printf "%.0f", (a + c)/1024  }' /proc/meminfo)
echo $available | awk '{ printf "%0.2fGb\n", $1/1024 }'


```

### print section of file based on line numbers

```bash
awk 'NR==<START>,NR==<END>'
```

### awk: number each line

```bash
awk '{ print FNR "\t" $0 }'
```

### numerical constants

```bash
# Decimal: the default
$ let "dec = 32"
$ echo "decimal number = $dec"
32

# Octal: numbers preceded by '0' (zero)
$ let "oct = 032"
$ echo "octal number = $oct"
26

# Hexadecimal: numbers preceded by '0x' or '0X'
$ let "hex = 0x32"
$ echo "hexadecimal number = $hex"
50

$ echo $((0x9abc))
39612

# Other bases: BASE#NUMBER
# BASE between 2 and 64.
# NUMBER must use symbols within the BASE range, see below.

$ let "bin = 2#111100111001101"
$ echo "binary number = $bin"
31181

$ let "b32 = 32#77"
$ echo "base-32 number = $b32"
231

# This notation only works for a limited range (2 - 64) of ASCII characters.
# 10 digits + 26 lowercase characters + 26 uppercase characters + @ + _
$ let "b64 = 64#@_"
$ echo "base-64 number = $b64"
4031
```

### downloading certs

```bash
openssl s_client -showcerts -servername gitlab.com -connect gitlab.com:443 < /dev/null | openssl x509 > gitlab-cert.pem
mv example gitlab-cert.pem /usr/local/share/ca-certificates/gitlab-cert.crt
```

### oneliner: print true color

```bash
for i in {1..255}; do echo -en "\e[38;5;${i}m[$i]\e[0m"; ! (($i%15)) && echo; done
```

### get active sessions on server

```bash
head -n 20 /run/systemd/users/[0-9]*

```

### Informing user about errors

```bash
LOGFILE="log.log"
exec 3>&1 1>"$LOGFILE" 2>&1
set -x
trap "echo 'ERROR: An error occurred during execution, check log $LOGFILE for details.' >&3" ERR
```

### awk - filter out rows with column less than value

```bash
awk '$3 >= 1000'
```

### true color vs 8bit

```bash
# 8 bit (5;)
for COLOR in {1..255}; do  echo -e "\e[38;5;${COLOR}m${COLOR}\e[0m"; done

# true color (2;)
# TBA

```

### systemctl - service dependencies

```bash
systemctl show -p "Wants" multi-user.target
```

### generate box-drawing symbols

```bash
for j in {0..9}; do (for i in {0..9} {A..F}; do echo -e "u25${j}${i} \u25${j}${i}"; done); done
```

### wget - download all files from site

```bash
wget -m -p -k -np -R '*html*,*htm*,*asp*,*php*,*css*,*gif*' -X 'www' <URL>
```

### awk - display line length

```bash
awk '{print length}'
```

### unicode chart

```bash
(for k in {0..3}; do for j in {0..9}; do for i in {10..99}; do echo -e "u${k}${j}${i} \u${k}${j}${i}"; done; done; done)
```

### awk - add all numbers in row (horizontally)

```bash
awk '{for(i=t=0;i<NF;) t+=$++i; $0=t}1'
```

### gpg - verify the validity of cygwin setup binary

```bash
# First, import the key with:
gpg --import pubring.asc
# gpg --list-keys

# Now you can verify this signature against your list of public keys:
gpg --verify setup-x86_64.exe.sig setup-x86_64.exe
```

### awk - NF and NR

```bash
$ ls -laptr |awk 'END {print NF}'
10
```

### git - create empty branch

```bash
# create new empty branch
git checkout --orphan NEWBRANCH
git rm -rf .

# reset head to empty branch
touch .gitignore && git add .gitignore
git commit -m "Initialize with .gitignore"
git checkout main
git reset --hard NEWBRANCH
```

### gpg - encrypt file (binary output)

```bash
echo 'helloooooo' >password.txt
SECRET_PASSPHRASE=hello

# encrypt file (creates password.txt.gpg)
gpg --symmetric --cipher-algo AES256 password.txt

# decrypt
gpg --quiet --batch --yes --decrypt --passphrase="$SECRET_PASSPHRASE" --output /tmp/password.txt password.txt.gpg
```

### jq - convert graphql query for curl

```bash
CURL_GRAPHQL_QUERY="$(
  jq -c -n --arg query '{...}' '{"query":$query}'
)"
```

### jq - json2csv

```bash
jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv'
```

### python systemd journal support

```bash
# prereq
yum install python36-devel systemd-devel -y
pip install systemd

# write journal entry from python
python3 -c 'from systemd import journal; journal.write("Hello Lennart")'

$ journalctl -n 3
-- Logs begin at Thu 2022-12-01 09:34:53 CST, end at Tue 2022-12-06 22:39:54 CST. --.
Dec 06 22:39:21 awxserver.example.com rc.local[1274]: oswbb heartbeat:Tue Dec 6 22:39:21 CST 2022
Dec 06 22:39:51 awxserver.example.com rc.local[1274]: oswbb heartbeat:Tue Dec 6 22:39:51 CST 2022
Dec 06 22:39:54 awxserver.example.com python3[109659]: Hello Lennart

```

### systemd-cat - connect a pipeline or program's output with the journal

```bash
$ echo "annie is cool" | systemd-cat -t nntrn

$ journalctl -o export -n 1
__CURSOR=s=56a4a698d04f478889d273caff148fde;i=1b287;b=18c4816e4c984fc79f80e5e7f8b0833a;m=6b7499c4a8;t=5ef359bd7de43;x=2520f3cb8f49f1d8
__REALTIME_TIMESTAMP=1670388410474051
__MONOTONIC_TIMESTAMP=461517735080
_BOOT_ID=18c4816e4c984fc79f80e5e7f8b0833a
PRIORITY=6
_MACHINE_ID=21e762519e7246a4b97b5fa8e94a7ed1
_HOSTNAME=awxserver.us.example.com
_UID=0
_GID=0
_TRANSPORT=stdout
SYSLOG_IDENTIFIER=nntrn
MESSAGE=annie is cool
_STREAM_ID=58e9f43495f7428b8ec4b4c4aaac754d
_PID=111536

$ journalctl -t nntrn
-- Logs begin at Thu 2022-12-01 09:34:53 CST, end at Tue 2022-12-06 22:27:21 CST. --
Dec 06 22:27:21 hostname.amer.com nntrn[106134]: hello world

```

### Manually delete journal entries

```bash
# retain logs from last <N>[s,m,h,days,months,weeks,years]
journalctl --flush --rotate
journalctl --vacuum-time=10days

# retains the last 400MB files.
journalctl --flush --rotate
journalctl --vacuum-size=400M

# retains last 2 files
journalctl --flush --rotate
journalctl --vacuum-files=2
```

### get all manpaths for commands in $PATH

```bash
while read line; do whereis -m ${line}/*; done < <(echo $PATH | tr ":" "\n")
```

### color output in the console

```bash
# standard colors
for C in {40..47}; do echo -en "\e[${C}m$C "; done

# high intensity colors
for C in {100..107}; do echo -en "\e[${C}m$C "; done

# 256 colors
for C in {16..255}; do echo -en "\e[48;5;${C}m$C "; done
for C in {0..255}; do tput setab $C; echo -n "$C "; done

```

### How to remove systemd services

```bash
systemctl stop [servicename]
systemctl disable [servicename]
rm /etc/systemd/system/[servicename]
rm /etc/systemd/system/[servicename] # and symlinks that might be related
rm /usr/lib/systemd/system/[servicename] 
rm /usr/lib/systemd/system/[servicename] # and symlinks that might be related
systemctl daemon-reload
systemctl reset-failed
```

### ldifde - Active Directory Schema

```bash
ldifde -f person-ldap.txt -d "CN=Fname Lname,OU=Users,OU=Austin,DC=amer,DC=example,DC=com"

```

### list  all mounted filesytems or search for a filesystem

```bash
findmnt --fstab
```

### Verifying Which Ports Are Listening

```bash
netstat -pan -A inet,inet6 | grep -v ESTABLISHED
```

### get return status of pipe commands

```bash
RC=( "${PIPESTATUS[@]}" )
```

### jq - convert kv to json froms stdin

```bash
jq -Rn '[(inputs | split(" ")) | .[] | split("=") | {key: .[0], value: .[1]}] | from_entries'

```

### jq group by with count

```bash
jq 'group_by(.language)| map( {"\(.[0].language)":length}) |add'

```

### jq - recursively slice array values to get first child only

```bash
jq 'walk(if type == "array" then (.[0]) else . end)'
```

### jq - merge files

```bash
jq -s '.[0] + .[1]' file1.json file2.json
```

### jq - filter dates

```bash
jq '[.[] | select(.date_field> (now | strftime("%Y-%m-%d")))]'
```

### convert between hex and ascii text

```bash
HEX_TEXT=68656c6c6f20776f726c64
ASCII_TEXT="hello world"

# hex to ascii
echo -n "$HEX_TEXT" | sed 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/gI' | xargs printf && echo ''

# ascii to hex
echo -n "$ASCII_TEXT" | od -A n -t x1 | tr -d ' '

```

### cvtsudoers - get all configured sudo policies

```bash
cp /etc/sudoers . 

# json
cvtsudoers -f json -o sudoers.json sudoers

# combines all /etc/sudoers.d/* and /etc/sudoers
cvtsudoers -f sudoers -o sudoers.txt sudoers


```

### get machine architecture.

```bash
architecture=""
case $(uname -m) in
    i386)   architecture="386" ;;
    i686)   architecture="386" ;;
    x86_64) architecture="amd64" ;;
    arm)    dpkg --print-architecture | grep -q "arm64" && architecture="arm64" || architecture="arm" ;;
esac
```

### jq - select objects with given key name

```bash
jq '..|objects|select(has("updateDate"))|.updateDate'
```

### rpm - get scripts used during install/uninstall processes

```bash
rpm -q  --scripts <PACKAGE_NAME>
```

### echo text N times

```bash
echo text{,,,,,,,,,,}
```

### draw honeycomb

```bash
yes "\\__/ " | tr "\n" " " | fold -$((($COLUMNS-3)/6*6+3)) | head -$LINES
```

### get current time in seconds

```bash
printf '%(%s)T\n' -1
```

### create and delete temp directory

```bash
dir=$(mktemp -d dist.XXXXXX)
trap 'rm -r "$dir"' EXIT
```

### Display all established ssh connections

```bash
ss -o state established '( dport = :ssh or sport = :ssh )'
```

### yum update security

```bash
YUM_OPTIONS="--disablerepo=* --enablerepo=OEL*,*KernelCare*,AppStream*"
yum ${YUM_OPTIONS}  check-update

yum ${YUM_OPTIONS} repolist
yum ${YUM_OPTIONS} updateinfo list installed cves
yum ${YUM_OPTIONS} updateinfo list installed

yum ${YUM_OPTIONS} update --security
```

### example showing locale set between "C" and en_US.UTF-8

```bash
$ cat letters.txt
b
B
A
c
a
C
D
d

$ LC_ALL=en_US.UTF-8 sort letters.txt
a
A
b
B
c
C
d
D

$ LC_ALL="C" sort letters.txt
A
B
C
D
a
b
c
d

```

### simple token generator

```bash
$ SALTSTRING=cheeseburger
$ openssl dgst -sha256 -hex <<<$(date +"%F %R $SALTSTRING") | awk '{print $NF}' | tr -d '[:alpha:]' | fold -w 8
```

### sed - extract lines between two tags

```bash
# include tags
sed -n '/<tag/,/<\/tag/ p'

# get inner lines only
sed -n '/<ul/,/<\/ul/ {//! p}' 
```

### date - get seconds at 00:00:00 for date

```bash
date -d "$(date +%F)" +%s

```

### generate ansible-vault like hash

```bash
$ openssl passwd -5 -salt VAULT  password
$5$VAULT$QuHvYEpH9XsW9SVsKimTvMdRykrd2g3UiAi.fO7MAhB

```

### jq - download and extract all the files from a gist

```bash
eval "$(
  curl -s https://api.github.com/gists/b787f3e14f28de11af45b1c7ec0ffbbc|
    jq -r '.files | to_entries | .[].value | @sh "echo \(.content) | tee \(.filename)"'
)"

```

### find and remove files older than date

```bash
find /tmp -mindepth 1 -maxdepth 1  ! -newermt 2022-01-01 -print -exec rm -rf {} \;
```

### bash - get last N characters

```bash
name="Annie Tran"
echo ${name: -3}

```

### prune example to filter files in .git/**

```bash
find . -type d -name ".git*" -prune -o -type f
```

### sed - delete lines between html tags

```bash
# delete lines between tags leaving tags:
sed '/<script>/,/<\/script>/{//!d}' 

# delete all lines between tags including tags:
sed '/<script>/,/<\/script>/d'
```

### awk - trim leading and trailing whitespace

```bash
awk '{$1=$1};1'
```

### cleanup git folder

```bash
git reflog expire --expire=now --all
git repack -ad  # Remove dangling objects from packfiles
git prune       # Remove dangling loose objects
```

### git reset - basic undo

```bash
# undo `git commit`
git reset --soft HEAD^

# undo `git add`
#    *  will untrack new files
git reset HEAD .
```

### pygmentize - create css file

```bash
STYLE=css
pygmentize -S $STYLE-f html -a .highlight >default.css
```

### pandoc - for loop to convert files

```bash
for f in *.html; do pandoc "$f" -t markdown_mmd-raw_html -o "${f%.*}.md"; done
```

### get source of minified javascript script

```bash
cat file.js.map | tr -d '\r' | jq -cr '.sourcesContent[]'
```

### dstat - get expensive processes

```bash
dstat -tcndylp --top-cpu
```

### openssl enc -encoding with iter

```bash
$ echo "password" | openssl enc -aes256 -k passphrase_aka_salt -base64 -iter 1000
U2FsdGVkX18vCTkI4x3csNp2FERhbXWY6HNSpyshkRY=

$ echo "U2FsdGVkX18vCTkI4x3csNp2FERhbXWY6HNSpyshkRY=" | openssl enc -aes256 -k passphrase_aka_salt -base64 -iter 1000 -d
password

```

### openssl-s_client, s_client - SSL/TLS client program

```bash
echo -n | openssl s_client -connect $HOSTNAME:443
```

### curl awx - view api

```bash
curl -s -k -u "admin:password" https://awxserver.example.com/api/v2/me/ | python -m json.tool

```

### zip - create zip file from list piped in stdin

```bash
<list of files> | zip name.zip --names-stdin
```

### set allexport - sourcing key/value .env files (without prefixing export)

```bash
set -o allexport
source .env
set +o allexport
```

### github release api - upload asset file

```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: $(file -b --mime-type $FILE)" \
  --data-binary @$FILE \
  "https://uploads.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/$GITHUB_RELEASE/assets?name=$(basename $FILE)"
```

### docker -  get IP address of a running container

```bash
docker inspect --format '{{range .NetworkSettings.Networks}} {{.IPAddress}} {{end}}' $CONTAINER_NAME
```

### ansible setup module - adhoc command for gathering facts

```bash
# Display facts from all hosts and store them indexed by I(hostname) at C(/tmp/facts).
# ansible all -m setup --tree /tmp/facts

# Display only facts regarding memory found by ansible on all hosts and output them.
# ansible all -m setup -a 'filter=ansible_*_mb'

# Display only facts returned by facter.
# ansible all -m setup -a 'filter=facter_*'

# Collect only facts returned by facter.
# ansible all -m setup -a 'gather_subset=!all,!any,facter'

# Display only facts about certain interfaces.
# ansible all -m setup -a 'filter=ansible_eth[0-2]'

# Restrict additional gathered facts to network and virtual (includes default minimum facts)
# ansible all -m setup -a 'gather_subset=network,virtual'

# Collect only network and virtual (excludes default minimum facts)
# ansible all -m setup -a 'gather_subset=!all,!any,network,virtual'

# Do not call puppet facter or ohai even if present.
# ansible all -m setup -a 'gather_subset=!facter,!ohai'

# Only collect the default minimum amount of facts:
# ansible all -m setup -a 'gather_subset=!all'

# Collect no facts, even the default minimum subset of facts:
# ansible all -m setup -a 'gather_subset=!all,!min'

# Display facts from Windows hosts with custom facts stored in C(C:\\custom_facts).
# ansible windows -m setup -a "fact_path='c:\\custom_facts'"
```

### docker format results

```bash
docker ps --format "{{json .}}"
```

### openssl-dgst - hash salted password

```bash
echo -n "$salt$password" | openssl dgst -r -sha1
```

### last reboot -  list of the times and dates when the system was recently rebooted

```bash
last reboot
```

### MemAvailable - memory tracker: get reclaimable memory from /proc/meminfo

```bash
awk '/^MemAvailable:/ {print $2}' /proc/meminfo
```

### clone gitlab project using project token

```bash
GITLAB_PROJECT_TOKEN=glpat-9eAicfQ9HoLp2ilItrVZ
git clone https://gitlab-ci-token:$GITLAB_PROJECT_TOKEN@gitlab.example.com/path/to/project.git

git clone -c http.sslVerify=false  https://gitlab-ci-token:$GITLAB_PROJECT_TOKEN@gitlab.example.com/infrastructure/database/devops/tower/inventory.git
```

### exec vs eval - process

```bash
# eval
bash -c 'echo $$ ; ls -l /proc/self ; echo foo'

# exec
bash -c 'echo $$ ; exec ls -l /proc/self ; echo foo'
```

### gitlab - clone using personal token

```bash
git clone https://oauth2:personal_token@gitlab.com/username/project.git 
```

### iconv - convert text encoding

```bash
iconv -f ISO-8859-1 -t UTF-8 filename.txt
```

### curl - api to get definition

```bash
curl dict://dict.org/d:$WORD
```

### && and || - compare strings using logical operators

```bash
[[ "string1" == "string2" ]] && echo "Equal" || echo "Not equal"
```

### IFS - word splitting observed in for loops

```bash
IFS=$' '
items="a b c"
for x in $items; do
    echo "$x"
done

IFS=$'\n'
for y in $items; do
    echo "$y"
done
```

### cp - brace expansion to copy/backup file

```bash
cp snippets.json{,.bkp}
```

### () - subshell and variable assignment

```bash
$ ANNIE=isme

$ (echo $ANNIE; export ANNIE=nntrn; echo $ANNIE)
isme
nntrn

$ echo $ANNIE
isme

```

### cat - short read about useless use

```bash
# Problematic code:
cat file.txt | awk '{print $1}'

# Correct code:
< file.txt awk '{print $1}'

# source: https://www.shellcheck.net/wiki/SC2002
```

### jq - convert json to environment variables

```bash
jq -rc 'to_entries | map("\(.key)=\(.value)")
```

### jq - extract keys/values from object

```bash
# get values
echo '{ "a": 1, "b": 2 }' | jq '.[]'

# get keys
echo '{ "a": 1, "b": 2 }' | jq 'keys | .[]'
```

### lvm - increase capacity of partition

```bash
FILESYSTEM_PATH=/dev/mapper/osvg-var.fs

# get max allocation size to expand later
vgdisplay

# get PV filesystem path
df -h 

# increase logical volume
lvextend -L +5G $FILESYSTEM_PATH

# expand filesystem so changes can be reflected in df -h
xfs_growfs $FILESYSTEM_PATH
```

### ${0%/*} - get directory of running script

```bash
echo "${0%/*}"
```

### curl - display information after transfer

```bash
curl -s -o snippets.json -w '%{json}' https://raw.githubusercontent.com/nntrn/sshell/data/snippets.json | jq
```

### awk - remove duplicates without sorting

```bash
# from file
awk '!a[$0]++'  file.txt

# from stdin
echo "..." | awk '!a[$0]++'  
```

### ignore carriage return in windows

```bash
set -o igncr
```

### python - command line pretty print json

```bash
python3 -m json.tool file.json

# or
cat file.json | python3 -m json.tool
```

### gitlab - create project

```bash
PROJECT_NAME=test
GITLAB_PERSONAL_ACCESS_TOKEN=...

curl --silent --header "PRIVATE-TOKEN: $GITLAB_PERSONAL_ACCESS_TOKEN" \
  -XPOST "https://gitlab.example.com/api/v4/projects?name=$PROJECT_NAME&visibility=private&initialize_with_readme=true"

```

### jq - convert json to csv

```bash
echo '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]' |
  jq -r '.[] | map(.) | @csv'

```

### grep - display lines in file1 that aren't in file2 (similar to comm)

```bash
grep -vFxf file1.txt file2.txt
```

### declare - list all function names

```bash
declare -F
```

### nmap - view open ports

```bash
nmap --open $HOSTNAME
```

### csplit - split text in file on empty lines

```bash
csplit --suppress-matched $FILENAME '/^$/' '{*}'
```

### rpm - get all installed doc files for packages

```bash
rpm -qa -d
```

### xargs - pretty print process environment

```bash
xargs -n 1 -0 </proc/$PID/environ
```

### nmap - scan port

```bash
nmap -p 443 $HOSTNAME
```

### jq - get unique items based on key

```bash
echo '[{"foo": 1, "bar": 123}, {"foo": 1, "bar": 123}, {"foo": 4, "bar": 123}]' | jq 'unique_by(.foo)'
```

### git - get remote branches

```bash
git remote show origin | sed -n '/Remote branches/,/Local/p' | grep -v ':' | awk '{print $1}'
```

### git log - get commit hash list

```bash
# get last 2 
git log -2 --pretty=%h 

# get all
git log --pretty=%h 
```

### git-gc - cleanup unnecessary files and optimize the local repository

```bash
git gc --aggressive --prune=all 
```

### github api - render a markdown document as an HTML page

```bash
curl -sL -X POST --data-binary @readme.md  https://api.github.com/markdown/raw --header "Content-Type:text/x-markdown" 

```

### fuser - close tcp ports

```bash
fuser -v -k -n tcp 443
fuser -v -k -n tcp 80
```

### openssl - create and verify CSR

```bash
# Creating Your CSR with One Command
openssl req -new \
-newkey rsa:2048 -nodes -keyout $HOSTNAME.key \
-out $HOSTNAME.csr \
-subj "/C=US/ST=Texas/L=Austin/O=$USER, Inc./OU=IT/CN=localhost"

# Verifying CSR Information
openssl req -text -in $HOSTNAME.csr -noout -verify
```

### unset variables beginning with

```bash
unset "${!VSCODE@}"
```

### find - search files modified in last 24 hours

```bash
find $HOME -mtime 0
```

### powershell - get all Get- commands

```bash
#C:/Windows/System32/WindowsPowerShell/v1.0/Modules
find . -type f -name "*.psd1" -print -exec cat {} \; | tr -d '\r' | tr -d '\0' | grep -Eo 'Get-[a-zA-Z\-]+' | sort -u | tee ~/all_powershell_get.txt

```

### curl - search dictionaries

```bash
# list dictionaries
curl dict://dict.org/show:db

# search word in a specific dictionary
curl dict://dict.org/d:computer:fd-eng-tur

```

### wget2 - get site stats and download files

```bash
wget2 --stats-site=csv:out.csv --recursive kernel.org/doc/Documentation/process/
```

### jq - target objects in array using key

```bash
echo '[{"id": "first", "val": 1}, {"id": "second", "val": 2}]' | jq '.[] | select(.id == "second")'
```

### naive string encryption - scramble numbers in string to hide sensitive data

```bash
echo "$text-to-scramble-numbers"  | tr "0123456789" "$RANDOM$RANDOM"

# or
randomnumstring=$RANDOM$RANDOM$RANDOM
echo "$text-to-scramble-numbers"  | tr "0123456789" $( echo ${randomnumstring:0:9})
```

### netsh - find the processId for the registered urls

```bash
netsh http show servicestate view=requestq verbose=no

```

### netsh -  Lists all defined aliases

```bash
netsh show helper
```

### pidstat - display global page faults and memory statistics

```bash
pidstat -C "awx | postgres" -r -p ALL
```

### get docker gateway

```bash
ip route show | grep docker0 | awk '{print $9}'
```

### nmap - list open TCP ports

```bash
nmap -sT -O  10.171.230.150
```

### systemctl - view status for every loaded service on the system

```bash
systemctl status --type=service
```

### journalctl - get entries for service

```bash
journalctl -u  <service>
```

### ps - find service using the most memory

```bash
ps aux --sort=-%mem

```

### systemd - files and tools that manage the Linux startup sequence

```bash
ll /etc/systemd/system/multi-user.target.wants
```

### openssl - generate a set of prime numbers

```bash
# define start and ending points
AQUO=10000
ADQUEM=10100
for N in $(seq $AQUO $ADQUEM); do
  # use bc to convert hex to decimal
  openssl prime $N | awk '/is prime/ {print "ibase=16;"$1}' | bc
done
```

### openssl - MD5, SHA1, and SHA256 digest

```bash
$ openssl dgst -md5 README
MD5(README)= 18ecc2fc65853262f250548e476d0e29

$ openssl dgst -sha1 README
SHA1(README)= b018bfbdd6b6c939ea6acb3b4ea591e214a2a84d

$ openssl dgst -sha256 README
SHA256(README)= d173e8ad75a8abbed8d21d4924ce145af7331f27a1a7b31e79e57271888ad54f

```

### openssl - extract information from a certificate

```bash
$ openssl x509 -noout -in cert.pem -issuer
issuer= /C=US/ST=Texas/L=Round Rock/O=example=Technologies/CN=example=Technologies Issuing CA 101

$ openssl x509 -noout -in cert.pem -subject
subject= /C=US/ST=Texas/L=Round Rock/O=example=OU=example=Digital/CN=awxserver.example.com

$ openssl x509 -noout -in cert.pem -dates
notBefore=Jul 14 18:17:08 2021 GMT
notAfter=Jul 14 18:17:08 2023 GMT

$ openssl x509 -noout -in cert.pem -issuer -subject -dates
issuer= /C=US/ST=Texas/L=Round Rock/O=example=Technologies/CN=example=Technologies Issuing CA 101
subject= /C=US/ST=Texas/L=Round Rock/O=example=OU=example=Digital/CN=awxserver.example.com
notBefore=Jul 14 18:17:08 2021 GMT
notAfter=Jul 14 18:17:08 2023 GMT

$ openssl x509 -noout -in cert.pem -hash
91b885cd

$ openssl x509 -noout -in cert.pem -fingerprint
SHA1 Fingerprint=E3:EB:7B:6B:01:2D:CE:3A:AD:63:00:AA:0B:60:08:F8:64:9F:1E:D9

```

### openssl - list high encryption ciphers using the AES algorithm

```bash
openssl ciphers -V 'AES+HIGH'
```

### sssctl - get command usage from help

```bash
sssctl --help
```

### jq - decode base64

```bash
jq -r --arg key content '.[$key] | gsub("\n";"") | @base64d' 
```

### sudo - show root entries only

```bash
sudo -ll | sed -n '/RunAsUsers: root/,/Sudoers entry/p'
```

### awk - split string into maxtrix-like table

```bash
echo "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O" | awk -v RS='[,\n]' '{a=$0;getline b; getline c; print a,b,c}' OFS=,
```

### sed - prepending and appending to file/line

```bash
s/^/"/g; - prepend double quotes to each line
s/$/"/g; - append double quotes to each line
1s/^/export json = \n/; - prepend to file
$s/$/\n); - append to file
```

### vault - get openapi specs

```bash
curl -H "X-Vault-Token: $VAULT_TOKEN" "$VAULT_ADDR/v1/sys/internal/specs/openapi"
```

### openssl - for versions >1.1.1

```bash
ENCRYPTEDFILE=.secrets.enc
SALTFILE=.vault-password
SECRETSFILE=.env

# encrypt
openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -base64 -salt -in $SECRETSFILE -out $ENCRYPTEDFILE -pass file:$SALTFILE

# decrypt
openssl enc -d -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -base64 -salt -in $ENCRYPTEDFILE -pass file:$SALTFILE
```

### prometheus - curl metrics

```bash
curl http://127.0.0.1:9190/integrations/node_exporter/metrics
```

### ls - sortable ls

```bash
ls -lptr --time-style='+%s %FT%T' --no-group --group-directories-first 
```

### vault - enable and write userpass

```bash
vault auth enable userpass
vault write auth/userpass/users/annie_tran password=secret
```

### get environment names matching prefix

```bash
${!prefix*}
${!prefix@}
```

### Get the parent directory of where this script is.

```bash
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )/.." && pwd )"

```

### investigate sockets & processes

```bash
$ ss -tulnp
.. users:(("node_exporter",pid=58451,fd=3))

$ PID=58451
$ cat /proc/$PID/cmdline
/opt/prometheus/exporters/node_exporter_current/node_exporter--no-collector.xfs--no-collector.mdadm--no-collector.textfile--web.listen-address=0.0.0.0:9100--log.level=info

$  procinfo $PID
```

### vault - list secrets in path

```bash
vault kv list -format=json 'kv/awx/svc_accounts/'
```

### curl - renew vault token

```bash
curl -X PUT -H "X-Vault-Namespace: infrastructure/database/engineering" -H "X-Vault-Request: true" -H "X-Vault-Token: $VAULT_TOKEN)" -d '{"increment":"24h"}' https://hcvault.example.com/v1/auth/token/renew-self
```

### vault - update secret with file

```bash
vault kv put 'kv/path/to/secrets' @file-with-object.json
```

### find directories that do not have sticky bit for group

```bash
find $DIR -maxdepth 3 -mindepth 1 -type d ! -perm -2000 -print -exec chmod g+s {} \;
```

### git - get top level directory

```bash
git rev-parse --show-toplevel
```

### prettier - alias for stdin formatting for xml files

```bash
alias prettier-xml='prettier --bracket-same-line true --xml-whitespace-sensitivity ignore --tab-width 2 --print-width 120 --stdin-filepath  *.xml'
```

### powershell - run noprofile command in shell (bash)

```bash
powershell -noprofile -command "<command to run>"
```

### git - remove commits matching pattern in message

```bash
git filter-branch --commit-filter '
    if [ `git rev-list --all --grep "<PATTERN TO REMOVE>" | grep -c "$GIT_COMMIT"` -gt 0 ]
    then
        skip_commit "$@";
    else
        git commit-tree "$@";
    fi' HEAD
```

### ansible-vault - encrypt string with vault id

```bash
echo -n 'letmein' | ansible-vault encrypt_string --vault-id dev@a_password_file --stdin-name 'db_password'
```

### uuidgen - create a new UUID value

```bash
uuidgen --sha1 --namespace @dns --name "string_to_hash"
```

### find files created in the last hour

```bash
find . -mindepth 1 -maxdepth 1 -type d -ctime 0 -print
```

### systemd-escape - escape strings

```bash
systemd-escape -u 'Hall\xc3\xb6chen\x2c\x20Meister'
```

### openssl salted encryption/decryption

```bash
echo 'example' >.vault-password
echo 'username: password' >.secrets

#encrypt
openssl enc -aes256 -base64 -salt -in .secrets -out .secrets.enc -pass file:./.vault-password

#decrypt
openssl enc -d -aes256 -a -in .secrets.enc -pass file:./.vault-password
```

### openssl crypt-style password hash

```bash
$ openssl passwd MySecret
8E4vqBR4UOYF.

$ openssl passwd -salt 8E MySecret
8E4vqBR4UOYF.
```

### openssl benchmark

```bash
openssl speed

```

### stat - display file properties

```bash
stat --printf='%U\n%G\n%z\n' $FILEORDIR
```

### systemctl examples

```bash
## VIEWING systemd INFORMATION

systemctl list-dependencies # Show a unit’s dependencies
systemctl list-sockets      # List sockets and what activates
systemctl list-jobs         # View active systemd jobs
systemctl list-unit-files   # See unit files and their states
systemctl list-units        # Show if units are loaded/active
systemctl get-default       # List default target (like run level)

## WORKING WITH SERVICES

systemctl stop service        # Stop a running service
systemctl start service       # Start a service
systemctl restart service     # Restart a running service
systemctl reload service      # Reload all config files in service
systemctl daemon-reload       # Must run to reload changed unit files
systemctl status service      # See if service is running/enabled
systemctl --failed            # Shows services that failed to run
systemctl reset-failed        # Resets any units from failed state
systemctl enable service      # Enable a service to start on boot
systemctl disable service     # Disable service--won’t start at boot
systemctl show service        # Show properties of a service (or other unit)
systemctl edit service        # Create snippit to drop in unit file
systemctl edit --full service # Edit entire unit file for service
H host status network         # Run any systemctl command remotely

## CHANGING SYSTEM STATES

systemctl reboot    # Reboot the system (reboot.target)
systemctl poweroff  # Power off the system (poweroff.target)
systemctl emergency # Put in emergency mode (emergency.target)
systemctl default   # Back to default target (multi-user.target)

## VIEWING LOG MESSAGES

journalctl                    # Show all collected log messages
journalctl -u network.service # See network service messages
journalctl -f                 # Follow messages as they appear
journalctl -k                 # Show only kernel messages
```

### openssl - verify checksum

```bash
openssl sha1 -sha256 file.txt | awk '{print $2}'
```

### print statistics of a process

```bash
prtstat $PID
```

### mpstat - processors related statistics.

```bash
mpstat 2 5

```

### read network interface statistics

```bash
ifstat -j -p
```

### procinfo: display all system status gathered from /proc

```bash
procinfo -a
```

### show most expensive CPU process

```bash
dstat --top-cpu

```

### gnu tools

```bash
man dstat
```

### list block devices

```bash
lsblk -a -p

```

### examples illustrating substring expansion

```bash
$ set -- 01234567890abcdefgh

$ echo ${1:7}
7890abcdefgh
$ echo ${1:7:0}

$ echo ${1:7:2}
78

$ echo ${1:7:-2}
7890abcdef

$ echo ${1: -7}
bcdefgh

$ echo ${1: -7:0}

$ echo ${1: -7:2}
bc

$ echo ${1: -7:-2}
bcdef
```

### systemctl - Get enabled services

```bash
systemctl list-unit-files --state=enabled --type=service --no-legend | awk '{print $1}'
```

### get non default values for ansible config

```bash
ansible-config dump | grep -v '\(default\)' | sed 's,(.*cfg),,g'
```

### disable login for domain user

```bash
echo '-:svc_user_account:ALL' | tee -a /etc/security/access.conf

```

### restart failed services

```bash
systemctl list-units --failed --no-legend | awk '{print $1}'| xargs -I % systemctl status % && systemctl restart %
```

### kill all processes for user

```bash
pkill -HUP -u annie_tran
```

### zip files in current directory

```bash
find . -maxdepth 1 -type d -exec zip archive.zip {} +
```

### Display the running processes of a container

```bash
$ docker top awx_task
```

### nstat (better way of getting network statistics)

```bash
nstat -a -t 60
```

### systemd-cgls: recursively show control group contents.

```bash
systemd-cgls
```

### Gather listening ports

```bash
netstat -ln --inet --program
```

### map view of pids owned by services

```bash
ps xawf -eo pid,user,cgroup,args
```

### clean docker (to factory)

```bash
# 1. Stop all containers
docker stop $(docker ps -aq)

# 2. Remove all containers
docker rm $(docker ps -aq)

# 3. Prune system
docker system prune -a --volumes

# 4. Remove all images
docker rmi $(docker images -q)
```

### Delete Orphaned Docker Volumes

```bash
docker volume rm $(docker volume ls -qf dangling=true)
```

### docker root systemd drop-in service

```bash
mkdir -p /u01/docker-root
rsync -a /var/lib/docker/* /u01/docker-root

echo '[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -g /u01/docker-root -H fd://' >>/etc/systemd/system/docker.service.d/docker.root.conf

systemctl daemon-reload
systemctl restart docker

```

### cygwin - open terminal here

```bash
echo 'cd "$OLDPWD"' >> .bashrc

C:\Users\annie_tran.AMERICAS\cyg\bin\bash --login -i

```

### find files created on this date

```bash
find /tmp -maxdepth 1 -type f -newermt 2022-02-02 ! -newermt 2022-02-04 -print -exec rm -rf {} \;
```

### cleanup leftover open files

```bash
kill -9 $(lsof |grep deleted|awk '{print $2}'|sort -u)
```

### awx - get token

```bash
get_token() {
echo "TOWER_HOST=http://$1" > 
  TOWER_HOST=http://$1 \
    TOWER_USERNAME=$2 \
    TOWER_PASSWORD=$3 \
    awx login -f human | sed 's,export ,,g' | tee -a ".${1%%.*}"
}
```

### du - aggregate directory size

```bash
du -h -d 1 .
```

### check memory usage per process

```bash
ps -eo pid,tid,class,rtprio,stat,vsz,rss,comm
```

### date unix timestamp to format

```bash
date -d @$TIMESTAMP
```

### build json using jq

```bash
str='delete delete modified other other other'
lstype=($(echo "$str"))
echo '{}' > files.json

for i in ${lstype[@]}; do
  cat files.json | jq ".$i[.$i|length] |= . + {\"date\": \"$(date +%F%X)\"}" >files.json
done
```

### create csv from json (jq)

```bash
wget -qO- http://programminghistorian.org/assets/jq_rkm.json | jq -r '.artObjects[] | [.id, .title, .principalOrFirstMaker, .webImage.url] | @csv'

```

### ps do not print columns

```bash
ps -o pid=''
```

### only get pid

```bash
ps -efo pid
```

### os detection

```bash
case "$OSTYPE" in
  solaris*) echo "SOLARIS" ;;
  darwin*)  echo "OSX" ;; 
  linux*)   echo "LINUX" ;;
  bsd*)     echo "BSD" ;;
  msys*)    echo "WINDOWS" ;;
  cygwin*)  echo "ALSO WINDOWS" ;;
  *)        echo "unknown: $OSTYPE" ;;
esac
```

### get name server

```bash
 host -t ns example com
```

### Check client certificate

```bash
echo '' | openssl s_client -connect awxserver.example.com:443 2>/dev/null | openssl x509 -text -noout | grep -A 1 "Public Key Algorithm"
```

### Cleaning up the VS Code Server on the remote

```bash
kill -9 `ps ax | grep "remoteExtensionHostAgent.js" | grep -v grep | awk '{print $1}'`
kill -9 `ps ax | grep "watcherService" | grep -v grep | awk '{print $1}'`
rm -rf ~/.vscode-server # Or ~/.vscode-server-insiders
```

### get process pid and parent id

```bash
ps -ax -o pid=,ppid=,command= | grep -v "\[" | sort -k3 -k2 -k1
```

### start ssh agent on login

```bash
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> .ssh/ssh-agent
   fi
   eval `cat .ssh/ssh-agent`
fi
```

### env reduced environment

```bash
env - PATH="$PATH" foo
```

### util linux

```bash
file_system=(cat chmod chown chgrp cksum cmp cp dd du df file fuser ln ls mkdir mv pax pwd rm rmdir split tee touch type umask)
processes=(at bg crontab fg kill nice ps time)
user_environment=(env exit logname mesg talk tput uname who write)
text_processing=(awk basename comm csplit cut diff dirname ed ex fold head iconv join m4 more nl paste patch printf sed sort strings tail tr uniq vi wc xargs)
shell_builtins=(alias cd echo test unset wait)
searching=(find grep)
documentation=(man)
software_development=(ar ctags lex make nm strip yacc)
miscellaneous=(bc cal expr lp od sleep true false)
```

### clear screen

```bash
alias cls='printf "\033c"'
```

### list files with time style & hides groups

```bash
ls -lptr --time-style='+%s %F %T' --group-directories-first -o
```

### zip directory

```bash
zip $ZIP_NAME.zip -r $DIRNAME
```

### random variable

```bash
echo "random: $RANDOM"
```

### date - get N days ago

```bash
date -d "$date -7 days" +"%Y-%m-%d"
```

### type - display information about command

```bash
type
```

### git diff side by side

```bash
git difftool -y -x sdiff

git difftool -y -x sdiff path/to/file
```

### List Network Facing Services

```bash
ss -atpu
```

### sendmail template

```bash
echo "To: annie_tran@example@com
Subject: my subject
Content-Type: text/html

$(cat test-html-email.html)" | sendmail -t

```

### sshpass - read ssh password from file

```bash
sshpass -f .secrets/sshpass/svc_npdbaasmongos ssh -o StrictHostKeyChecking=no svc_npdbaasmongos@cfiserver.example.com
```

### docker - resolve no space on device

```bash
systemctl stop docker
mv /u01/docker /u01/docker.bkp-$(date +%F)
mv /var/lib/docker /u01
mkdir -p /var/lib/docker
mount --rbind /u01/docker /var/lib/docker
systemctl start docker
```

### list files and sort by size

```bash
du -h | sort -rh
```

### Getting Server Certificate

```bash
$ openssl s_client -showcerts -connect awxserver.example.com:80
```

### curl vault secrets

```bash
VAULT_TOKEN=...

curl -H "X-Vault-Namespace: infrastructure/database/engineering/tools/dbaasv2/dbaasv2/" -H "X-Vault-Request: true" -H "X-Vault-Token: $VAULT_TOKEN" https://hcvault-nonprod.example.com/v1/kv/data/SERVICE_ACCOUNT/MONGO/NONPROD
```

### get git symlink files

```bash
git ls-files -s | awk '/120000/{print $4}'

```

### set existing variables only

```bash
: ${SETLANG="env LANG= LC_MESSAGES= LC_ALL= LANGUAGE="}
: ${MAKEINFO="makeinfo"}
: ${TEXI2DVI="texi2dvi"}
: ${DOCBOOK2HTML="docbook2html"}
: ${DOCBOOK2PDF="docbook2pdf"}
: ${DOCBOOK2TXT="docbook2txt"}
: ${GENDOCS_TEMPLATE_DIR="."}
: ${PERL='perl'}
: ${TEXI2HTML="texi2html"}
```

### delete null value

```bash
tr -d '\0'
```

### ansible-doc snippet

```bash
ansible-doc awx.awx.tower_ad_hoc_command --snippet

```

### Get commits that have deleted files

```bash
git log --diff-filter=D --summary
```

### proc environ - format for readability

```bash
cat /proc/$$/environ | sed 's/\([A-Z_]*=\)/\n\1/g'

```

### comm - find common or distinct lines between files

```bash
# find lines only in file1
comm -23 file1 file2 

# find lines only in file2
comm -13 file1 file2 

# find lines common to both files
comm -12 file1 file2 
```

### sort top command by memory

```bash
top -o +%MEM
```

### rbind mount docker

```bash
mount --rbind /u01/docker /var/lib/docker

```

### find js files in src/

```bash
find . -maxdepth 3 -type f -name "*.js" \( -path "*/src/*" -and ! -regex "*(node_modules|.git)*" \) -print

```

### Check and assign variables

```bash
echo "${VAR1:=default}"
```

### yum - get installed security updates

```bash
yum updateinfo list security installed
```

### ssh-keygen - generate public key from prviate key

```bash
ssh-keygen -y -f ~/.ssh/windows_login
```

### docker history

```bash
dockerprettyhist() {
  local imageid=${1:-44187ed3a967}
  docker history --no-trunc $imageid |
    tac | tr -s ' ' | cut -d " " -f 5- |
    sed 's,^/bin/sh -c #(nop) ,,g' | sed 's,^/bin/sh -c,RUN,g' |
    sed 's, && ,\n  & ,g' |
    sed 's,\s*[0-9]*[\.]*[0-9]*\s*[kMG]*B\s*$,\n,g' |
    head -n -1
  echo ""
}
```

### yum list docker-engine --showduplicates

```bash
yum list docker-engine --showduplicates
```

### umask - get umask for current process

```bash
grep '^Umask:' "/proc/$$/status"
```

### getfactl - get user, group, and perm

```bash
getfacl linux
```

### add user to group

```bash
usermod -a -G wheel annie_tran
```

### realpath - get relative paths

```bash
realpath --relative-to=$DIR1 $DIR2
```

### Print border

```bash
printf '=%.0s' {1..100}
```

### get latest kernel version

```bash
rpm -q kernel|awk -F- '{print $3}'|awk -F. '{print $1}'|sort -n|tail -1
```

### awx curl

```bash
curl -f -k -s -v -H "Content-Type: application/json" -X PUT -d @_ldap.json --user $TOWER_USERNAME:$TOWER_PASSWORD "https://$TOWER_HOST/api/v2/settings/ldap/"
```

### system boot menu entries

```bash
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
```

### get latest kernel

```bash
awk -F\' /^menuentry/{print\$2} /etc/grub2.cfg | grep -vE "(uek|rescue)" | sort | tail -n 1
```

### get installed kernels

```bash
awk -F\' /^menuentry/{print\$2} /etc/grub2.cfg
```

### awx job_template

```bash
awx job_template list --all -f human --filter 'id, name, playbook, modified, status'
```

### Uptime of a process

```bash
ps -o etimes -p $PID
```

### sha256

```bash
sha256() {
  if which sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  else
    shasum -a256 "$1" | awk '{ print $1 }'
  fi
}
```

### get ip address

```bash
/usr/sbin/ip a | grep inet
```

### generate random password openssl

```bash
openssl rand -base64 20
```

### python to encode and decode

```bash
# encode
python -m base64 -e <<< "sample string"

# decode
python -m base64 -d <<< "dGhpcyBpcyBlbmNvZGVkCg=="
```

### find world writable files

```bash
find / -type d -path "/misc*" -prune -o -type d -perm /o=w -print

find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print
```

### password generator

```bash
mkpasswd -l 15 -d 3 -C 5
```

### pmem (vscode mimics ps)

```bash
ps -ax -o pid=,ppid=,pcpu=,pmem=,command=
```

### remove trailing whitespace

```bash
awk '{$1=$1};1'
```

### /proc files

```bash
cat /etc/redhat-release
cat /etc/debian_version
cat /etc/os-release
cat /etc/issue
cat /etc/sysconfig/kernel
cat /proc/uptime
cat /proc/loadavg
cat /proc/vmstat
cat /proc/devices
cat /proc/diskstats
cat /proc/cmdline
cat /proc/mdstat
cat /proc/meminfo
cat /proc/swaps
cat /proc/filesystems
cat /proc/mounts
cat /proc/interrupts
cat /boot/grub/grub.conf
cat /proc/version
cat /proc/modules

```

### print files with timestamp

```bash
 find . -type f -printf '%TFT%TT %p\n'
```

### awk - remove duplicates without sorting

```bash
awk '!x[$0]++'
```

### Use awk to display text and insert blank line before

```bash
cat file.txt | awk -F '\t' '{print "\n"$2,$3}' OFS='\n'
```

### repeat string N times

```bash
printf '=%.0s' {1..80}

```

### get all processes for user

```bash
ps -U $USER -u $USER u
```

### get arguments after first

```bash
echo "${@:2}"
echo "${*:2}"

```

### get runas user

```bash
sudo --list | grep 'NOPASSWD: ALL' |  awk -F'[)(]' '{print $2}'
```

### string substring

```bash
STR="Hello world"
echo ${STR:6:5}   # "world"
echo ${STR: -5:5}  # "world"
```

### string slicing

```bash
name="John"
echo ${name}
echo ${name/J/j}    #=> "john" (substitution)
echo ${name:0:2}    #=> "Jo" (slicing)
echo ${name::2}     #=> "Jo" (slicing)
echo ${name::-1}    #=> "Joh" (slicing)
echo ${name:(-1)}   #=> "n" (slicing from right)
echo ${name:(-2):1} #=> "h" (slicing from right)
echo ${food:-Cake}  #=> $food or "Cake
```

### set color

```bash
SETCOLOR_SUCCESS="echo -en \\033[0;32m"
SETCOLOR_FAILURE="echo -en \\033[0;31m"
SETCOLOR_WARNING="echo -en \\033[0;33m"
SETCOLOR_RESET="echo -en \\033[0;39m"

```

### ss -  investigate sockets

```bash
ss -a
```

### sqlplus - set password

```bash
ORACLE_PWD=$1
ORACLE_SID="`grep $ORACLE_HOME /etc/oratab | cut -d: -f1`"
ORACLE_PDB="`ls -dl $ORACLE_BASE/oradata/$ORACLE_SID/*/ | grep -v pdbseed | awk '{print $9}' | cut -d/ -f6`"
ORAENV_ASK=NO
source oraenv

sqlplus / as sysdba << EOF
      ALTER USER SYS IDENTIFIED BY "$ORACLE_PWD";
      ALTER USER SYSTEM IDENTIFIED BY "$ORACLE_PWD";
      ALTER SESSION SET CONTAINER=$ORACLE_PDB;
      ALTER USER PDBADMIN IDENTIFIED BY "$ORACLE_PWD";
      exit;
EOF

```

### view process id

```bash
bash -c 'echo $$ ; ls -l /proc/self ; echo foo'
```

### exec cmd

```bash
bash -c 'echo $$ ; exec ls -l /proc/self ; echo foo'
```

### generate random password

```bash
tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 32
```

### run sudosu

```bash
eval "sudo $(sudo --list | grep -ws User -A 1000 | sed 's/,/\n/g' | sed 's/:/:\n/g' | grep '/bin/su' | sort | tail -n 1)"

```

### get allowed sudo commands

```bash
sudo --list | grep -ws User -A 1000 | sed 's/,/\n/g' | sed 's/:/:\n/g' | grep -E '^\s+?/' | sed -e 's/^[[:space:]]*//'
```

### get git status for all worktree repos in git

```bash
find . -maxdepth 3 -name .git -type d -print -exec git -C {} status \;
```

### find zombie processes

```bash
ps -elf | grep Z
```

### extract in a different directory

```bash
tar xvf filename.tar -C /home/username/

# extract to current directory
tar xvf filename.tar
```

### compress directory using tar

```bash
tar cjvf image_backup.tar.bz2 dirname

tar zcvf image_backup.tar.gz dirname
```

### get top memory/cpu hog

```bash
# get top memory hog
ps -eo user,pid,size,pcpu,cmd --sort=-size

# get top CPU hog
ps -eo user,pid,size,pcpu,cmd --sort=-pcpu
```

### Get systemctl property

```bash
systemctl show -p WantedBy grafana-agent.service

# view all
systemctl show grafana-agent.service
```

### docker volume - inspect all

```bash
docker volume inspect $(docker volume ls | awk '{print $2}' |  tail -n +2)
```

### generating crypto quote

```bash
$ special='! @ # % ^ & * ( ) _ + = [ ] { } < > . / ?'
$ abc=$(echo {a..z} {A..Z} {0..9} "$special" | tr -d ' ')
$ key=$(echo "$abc" | sed 's,\(.\),\1\n,g' | shuf | tr -d '\n')

```

### git diff tags

```bash
 git diff --minimal -w -b 17.0.1 17.1.0 installer
```

### sed - only print after matching pattern

```bash
sed -n '/^\[mongo:children.*/,$p'
```

### sed - delete rows after pattern

```bash
cat playbooks/hosts/prod.ini | sed -e '/^\[mongo:children/,+5000d'
```

### sed replace files

```bash
find . -type f -name "*.html" -print -exec sed -i -e 's/"\/\//"/g' {} \;
```

### sort .bash_history

```bash
cat .bash_history | grep -vE "^#[0-9]+" | sort | uniq -c | sort -k 1 -n | less

```

### self sign cert (generate private key, csr, and crt)

```bash
openssl req -new -newkey rsa:4096 -nodes -keyout "private.key" -out "$(hostname -f).csr" -subj "/C=US/ST=Texas/L=Round Rock/O=example=OU=example=Digital/CN=$(hostname -f)"

openssl x509 -signkey private.key -in $(hostname -f).csr -req -days 365 -out $(hostname).crt
```

### git pager

```bash
# Tells 'less' not to paginate if less than a page
export LESS="-F -X $LESS"

git config --global --replace-all core.pager "less -F -X"
```

### prune unwritable files from find

```bash
find /repository/images/database -type d ! -writable -prune -o -type f -group $USER -print -exec chown -c $USER.dbcore {} \;
```

### psql table size

```bash
psql -U awx -d awx -c "\dt+" -P pager=off |
  awk -F "|" '{print $2,$5}' |
  grep "_" |
  sort -k2 -rh |
  tee /tmp/awx_table_size.txt
```

### print all commands in $PATH (windows bash)

```bash
printcommands() {
  for i in $(echo "$PATH" | sed 's/:/\n/g' | grep -v ' '); do
    echo "#######################################################"
    echo "$i"
    echo "#######################################################"
    echo "$(find $i -maxdepth 2 -type f ! -name '*.dll' 2>&1 | grep -E "\/[a-z0-9]*$|*.exe$" | grep -v license)"
    echo ""
  done
}

printcommands | tee /tmp/window-commands.txt

```

### type

```bash
$ LC_ALL=C type foo
bash: type: foo: not found

$ LC_ALL=C type ls
ls is aliased to `ls --color=auto'

$ which type

$ LC_ALL=C type type
type is a shell builtin

$ LC_ALL=C type -t rvm
function

```

### ansible list all hosts

```bash
ansible all --list-hosts
```

### encrypt/decrypt gpg

```bash
encrypt () { gpg -ac --no-options "$1"; }
decrypt () { gpg --no-options "$1"; }
```

### ansible - transfer a file directly to many servers:

```bash
ansible all -m copy -a "src=ansible.cfg dest=/tmp/"
```

### See the list of available plugins

```bash
ansible-doc -t become -l
```

### generate ed25519 private key

```bash
openssl genpkey -algorithm ed25519
```

### rsync

```bash
rsync -avr -o -g filename.txt user@hosserver.example.com:/home/annie_tran
```

### create csr request

```bash
openssl req -new -newkey rsa:4096 -nodes -keyout "private.key" -out "$(hostname -f).csr" -subj "/C=US/ST=Texas/L=Round Rock/O=example=OU=example=Digital/CN=$(hostname -f)"
```

### print markdown docs not in node_modules

```bash
find . -type f -name "*.md" ! -path "*node_modules*" -print
```

### get most used commands

```bash
history | cut -d ' ' -f6- | sort | uniq -c | sort -k1 -nr
```

### print commands from sudo log

```bash
cat /var/log/sudo.log | grep "LANG=C;LANGUAGE=en" | cut -d';' -f3 | sort -u 
```

### view UDP and TCP ports

```bash
lsof -n -i TCP -i UDP
```

### output all yml

```bash
tmppath="/tmp/$(date +%F)/ansible-roles"
mkdir -p $tmppath
for d in $(find $PWD -mindepth 1 -maxdepth 1 -type d); do
  echo "$d"
  savename="${d//${PWD}\//}"
  find "$d" -type f -name "*.yml" -print -exec cat {} \; | sed -e 's@'"$(echo "$d")"'@'"$(echo "\n# file: $d")"'@g' | tee "$tmppath/${savename//[^a-zA-Z0-9.]/_}"
done
```

### encrypt string with ansible-vault

```bash
echo -n 'letmein' | ansible-vault encrypt_string --vault-id dev@a_password_file --stdin-name 'db_password'
```

### list all ip rules

```bash
iptables --list-rules -v
```

### get matching prefix

```bash
getsame() {
  string1=${1:?}
  string2=${2:?}
  first_diff_char=$(cmp <(echo "$string1") <(echo "$string2") | cut -d " " -f 5 | tr -d ",")
  echo ${string1:0:$((first_diff_char - 1))}
}
```

### greedy *

```bash
echo foo | sed 's/o*/EEE/'
```

### hack for exporting env variables

```bash
export $(cat /path/to/file.txt | grep -vE "^(#|export)" | grep ".")
```

### get modification date for files in directory

```bash
for pb in $(find . -maxdepth 1 -type f -name "*.yml"); do
  mod=$(stat -c %y $pb)
  echo -e "${mod%%\ *}, ${pb##\.\/}"
done

```

### view workstation details

```bash
net config workstation
```

### Recursively get full path name

```bash
ls -RA --ignore="\.*" /misc/software/database/awx | awk '
/:$/&&f{s=$0;f=0}
/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
NF&&f{ print s"/"$0 }'
```

### coreutils

```bash
# Output of entire files
cat tac nl od base64

# Formatting file contents
fmt pr fold

# Output of parts of files
head tail split csplit

# Summarizing files
wc sum cksum md5sum sha1sum sha2

# Operating on sorted files
sort shuf uniq comm ptx tsort

# Operating on fields
cut paste join

# Operating on characters
tr expand unexpand

# Directory listing
ls dir vdir dircolors

# Basic operations
cp dd install mv rm shred

# Special file types
mkdir rmdir unlink mkfifo mknod ln link readlink

# Changing file attributes
chgrp chmod chown touch

# Disk usage
df du stat sync truncate

# Printing text
echo printf yes

# Conditions
false true test expr

# Redirection
tee

# File name manipulation
dirname basename pathchk mktemp realpath

# Working context
pwd stty printenv tty

# User information
id logname whoami groups users who

# System context
date arch nproc uname hostname hostid uptime

# SELinux context
chcon runcon

# Modified command invocation
chroot env nice nohup stdbuf timeout

```

### get sorted size of directories in current working directory

```bash
du -h --max-depth=1 | sort -h
```

### Resolve warning that bridge-nf-call-iptables is disabled

```bash
modprobe br_netfilter
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.bridge.bridge-nf-call-ip6tables=1
```

### Get size of mounted filesystems

```bash
df --block-size=1 | numfmt --field 2 --header --to=iec
```

### alias for easy column extraction

```bash
alias c1="awk '{print \$1}'"
alias c2="awk '{print \$2}'"
alias c3="awk '{print \$3}'"
alias c4="awk '{print \$4}'"
alias c5="awk '{print \$5}'"
alias c6="awk '{print \$6}'"
alias c7="awk '{print \$7}'"
alias c8="awk '{print \$8}'"
alias c9="awk '{print \$9}'"
```

### fetch all git tags

```bash
git fetch --all --tags
```

### get free space on directory

```bash
df -Ph . 
```

### get free space in directory

```bash
df -Ph . 
```

### hack for unsourcing env variables

```bash
unset $(cat /path/to/file.txt | grep -vE "^(#|export)" | grep "." | cut -d = -f -1)
```

### echo shell commands as they are executed

```bash
exe() { echo "\$ $@" ; "$@" ; }
```

### print all the columns after a particular number using awk

```bash
ps -ef | awk -v m="\x01" -v N="8" '{$N=m$N ;print substr($0, index($0,m)+1)}'

```

### set timeout for script

```bash
/bin/timeout -s 2 10 /path/to/your/script.sh
```

### git make files executable

```bash
find . -type f -name "*.sh" | xargs -I {} git add --chmod=+x {}
```

### curl yum repo

```bash
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
yum install yarn
```

### set env variables

```bash
export $(egrep -v '^#' "path/to/file" | xargs)
```

### umask create file with permissions

```bash
(umask 077; touch file)  # creates a 600 (rw-------) file
(umask 002; touch file)  # creates a 664 (rw-rw-r--) file
```

### pip show for all pip installed

```bash
pip show $(pip list | awk '{print $1}' | grep -v - | xargs) | less
```

### capturing group grep

```bash
shopt -s extglob
shopt -s nullglob
shopt -s nocaseglob

ls +(.*) | while read file; do
  echo $file
  set -- $file
  [[ ! -z $2 ]] && echo "$1$2"
done
```

### docker history dockerfile

```bash
docker history --no-trunc <imageid> | tac | tr -s ' ' | cut -d " " -f 5- | sed 's,^/bin/sh -c #(nop) ,,g' | sed 's,^/bin/sh -c,RUN,g' | sed 's, && ,\n  & ,g' | sed 's,\s*[0-9]*[\.]*[0-9]*\s*[kMG]*B\s*$,,g' | head -n -1
```

### docker save images

```bash
dockerimagedir="docker-images-$(date +%F)"

mkdir -p dockerimagedir
docker save $(docker images -q) -o "$dockerimagedir/$(hostname -a).tar"
docker images | sed '1d' | awk '{print $1 " " $2 " " $3}' >  "$dockerimagedir/docker-images.list"

rsync -avr  -o -g $dockerimagedir servicedbaas@awxserver.example.com:/home/servicedbaas

docker load -i /path/to/save/mydockersimages.tar

while read REPOSITORY TAG IMAGE_ID
do
        echo "== Tagging $REPOSITORY $TAG $IMAGE_ID =="
        docker tag "$IMAGE_ID" "$REPOSITORY:$TAG"
done < "$dockerimagedir/docker-images.list"
```

### pip install requirements one line

```bash
 pip install --upgrade  $(cat requirements.txt | grep -o "^[^#].*")
```

### print env variables that start with S

```bash
env | grep -o '^S[^=]*'
```

### Parse a .env (dotenv) file directly using bash

```bash
export $(egrep -v '^#' .env | xargs)
```

### extract title from html

```bash
echo -e $html | grep -Eo "<title>(.*)</title>"
```

### rsync with exclude

```bash
rsync -avr --exclude={'dbaasv2-awx','*.rpm'} -o -g /home/servicedbaas servicedbaas@awxserver.example.com:/home/servicedbaas/01

rsync -avr --exclude={'dbaasv2-awx','ansible'} -o -g dbaas annie_tran@ausserver.example.com:/home/annie_tran


```

### view signed certs

```bash
find /etc/pki -type f ! -name "*cacerts*" -print -exec cat {} \; | less
```

### hash directory

```bash
find . -type f -print0 | sort -z | xargs -r0 sha256sum  sha256SumOutput

```

### print name + content

```bash
find . -type f -print -exec cat {} \; 
```

### diff project structures for git branches

```bash
diff --side-by-side --color=always --width=200 --suppress-common-lines \
  <(git ls-tree -r branch01--name-only) \
  <(git ls-tree -r branch02 --name-only)

```

### download & save as json

```bash
wget <url> -O file_name.json
```

### a fancier lsof -i

```bash
lsof -P -i -n
```

### get list of most used commands

```bash
COLUMN=4
history | awk '{a[$COLUMN]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
```

### Graph # of connections for each hosts.

```bash
netstat -an | grep ESTABLISHED | awk '{print $5}' | awk -F: '{print $1}' | sort | uniq -c | awk '{ printf("%s\t%s\t",$2,$1) ; for (i = 0; i < $1; i++) {printf("*")}; print "" }'
```

### ps examples

```bash
ps aux
ps -e
```

### print filename + content of sudo privileges

```bash
find /etc/sudoers.d/ -type f -print -exec cat {} \; | less
```

### create html toc

```bash
cat <<EOF >index.html
<html>
<body>
<ul>
$(find . | grep html | sed 's/\.\///g' | sed 's/^\([^ ]*\)/<li><a href="\1">\1<\/a><\/li>/')
</ul>
</body>
</html>
EOF
```

### urldecode

```bash
sed "s@+@ @g;s@%@\\\\x@g" | xargs -0 printf "%b"
```

### recursively download files from web

```bash
wget --no-parent -r https://url.com
```

### creating a user with pass

```bash
useradd -p $(openssl passwd -1 $PASS) $USER
```

### sending email

```bash
mail -s "$(echo -e "SAR files\nContent-Type: text/html")" annie_tran@example@com <allsar.txt

```

### Get active internet connections and domain sockets

```bash
netstat -pW
```

### unwrap text file (useful for logs)

```bash
sed ':a;N;$!{/\n$/!ba}; s/[[:blank:]]*\n[[:blank:]]*/ /g' textfile.txt
```

### clear pycache

```bash
find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
```

### print = across the screen

```bash
printf '=%.0s' $(seq 1 $(tput cols))
```

### Update multiple repos (no rev)

```bash
find . -maxdepth 3 -name .git -type d | cut -d '/' -f1,2 | xargs -I {} git -C {} pull
```

### view file structure (tree)

```bash
ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
```

### List full paths for recursive files with grep and awk

```bash
ls -R /path | awk '
/:$/&&f{s=$0;f=0}
/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
NF&&f{ print s"/"$0 }' | grep docx
```

### Updating Multiple Repos With One Command

```bash
find . -maxdepth 3 -name .git -type d | rev | cut -c 6- | rev | xargs -I {} git -C {} pull
```

### append group to a user

```bash
usermod -aG wheel username
```

### view os-release

```bash
cat /etc/os-release
```

### cf

```bash
cf login -a https://api.sr2.pcf.example.com
```

### rpm

```bash
RPMURL='https://...'
rpm -ivh $RPMURL
```

### test openssl connection

```bash
openssl s_client -connect github.com:443 -msg
```

### display information about the CPU architecture

```bash
lscpu
```

### start firewalld

```bash
sudo dnf install -y curl policycoreutils openssh-server perl
sudo systemctl enable sshd
sudo systemctl start sshd
# Check if opening the firewall is needed with: sudo systemctl status firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo systemctl reload firewalld

```

### find and kill processes

```bash
STRING_MATCH=""
lsof -i | grep $STRING_MATCH |  awk '{print $2}' | xargs kill
```

### host

```bash
host -w hostname
```

### pstree

```bash
pstree
```

### generate RSA key

```bash
openssl genpkey -out fd.key -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -aes-128-cbc
```

[Top](#top)

## cmd

### install optional feature using dism

```cmd
# get feature name
DISM.exe /Online /Get-Capabilities | find "Rsat.Active"

# download
DISM /Online /Add-Capability /CapabilityName:Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0


```

### Windows 10 TCP/IP Reset

```cmd
netsh winsock reset
netsh int ip reset
ipconfig /release
ipconfig /renew
ipconfig /flushdns
```

### netsh - loop over ip4 to display network information

```cmd
netsh interface ipv4 show | grep show awk '{print $2}' | xargs -I %  netsh interface ipv4 show %
```

### fsutil resource info

```cmd
fsutil resource info C:
```

### bat file for opening cygwin in current directory

```cmd
@echo off
setlocal enableextensions

set CURRENTDIR=%cd%

C:
chdir "%~dp0bin"
set TERM=

bash --login -i -c "eval \"cd '$CURRENTDIR'\";$SHELL"
```

### windows - repair health

```cmd
dism /online /cleanup-image /restorehealth
```

### view service account owner

```cmd
net user /domain svc_npdbaasoraos
```

[Top](#top)

## config

### enable ssh controlmaster - ssh sessions

```config
Host *
    ControlMaster auto
    ControlPath  ~/.ssh/sockets/%r@%h-%p
    ControlPersist  600
```

[Top](#top)

## javascript

### d3 - parse csv from string

```javascript
var csvString = `date,weekday,hour,pickup
2020-08-31,1,6,0
2020-08-31,1,7,5
2020-08-31,1,8,7
2020-08-31,1,9,7
2020-08-31,1,10,6
2020-08-31,1,11,10
2020-08-31,1,12,5
2020-08-31,1,13,6
2020-08-31,1,14,11`

// v5: https://d3js.org/d3.v5.js
var data = d3.csvParse(csvString)

// v3: https://d3js.org/d3.v3.js
var data = d3.csv.parse(csvString);

```

### document.documentElement.scrollTop - scroll to top of page

```javascript
function setScrollTopForDocument(doc = document, value = 0) {
  doc.documentElement.scrollTop = doc.body.scrollTop = value
}

```

### document.cookie - convert key=value string to JSON string

```javascript
Object.fromEntries(document.cookie.split('; ').map(e => e.split('=').map((s) => {
  let ret = unescape(decodeURI(s)).replace(/'/g, '"')
  try {
    ret = JSON.parse(ret)
  } catch (err) {}
  return ret
})))
```

### devtools: get all css items

```javascript
css = new Set(
  [
    ...$$('style[data-load-themed-styles]')
      .map(e =>
        e.innerText
          .replace(/(\u007D)/g, '$1\n')
          .split('\n')
          .filter(Boolean)
          .filter(p => p.indexOf('media') < 0)
          .filter(p => !/^[^_]+_[\d\w]+\s?{/.test(p))
          .filter(p => !/.*[\[\]].*/.test(p))
      )
      .flat(2),
  ]
    .filter(e => e.trim())
    .map(e => e.replace(/\n/g, '').split('{'))
    .map(c => c[0].split(',').map(a => a + '\u007B' + c[1]))
    .flat(2)
    .sort()
)

```

[Top](#top)

## nginx

### nginx -  common configurations to block sql injections and other attacks

```nginx
# common nginx configuration to block sql injection and other attacks
location ~* "(eval\()" {
    deny all;
}
location ~* "(127\.0\.0\.1)" {
    deny all;
}
location ~* "([a-z0-9]{2000})" {
    deny all;
}
location ~* "(javascript\:)(.*)(\;)" {
    deny all;
}

location ~* "(base64_encode)(.*)(\()" {
    deny all;
}
location ~* "(GLOBALS|REQUEST)(=|\[|%)" {
    deny all;
}
location ~* "(<|%3C).*script.*(>|%3)" {
    deny all;
}
location ~ "(\\|\.\.\.|\.\./|~|`|<|>|\|)" {
    deny all;
}
location ~* "(boot\.ini|etc/passwd|self/environ)" {
    deny all;
}
location ~* "(thumbs?(_editor|open)?|tim(thumb)?)\.php" {
    deny all;
}
location ~* "(\'|\")(.*)(drop|insert|md5|select|union)" {
    deny all;
}
location ~* "(https?|ftp|php):/" {
    deny all;
}
location ~* "(=\\\'|=\\%27|/\\\'/?)\." {
    deny all;
}
location ~ "(\{0\}|\(/\(|\.\.\.|\+\+\+|\\\"\\\")" {
    deny all;
}
location ~ "(~|`|<|>|:|;|%|\\|\s|\{|\}|\[|\]|\|)" {
    deny all;
}
location ~* "/(=|\$&|_mm|(wp-)?config\.|cgi-|etc/passwd|muieblack)" {
    deny all;
}

location ~* "(&pws=0|_vti_|\(null\)|\{\$itemURL\}|echo(.*)kae|etc/passwd|eval\(|self/environ)" {
    deny all;
}
location ~* "/(^$|mobiquo|phpinfo|shell|sqlpatch|thumb|thumb_editor|thumbopen|timthumb|webshell|config|settings|configuration)\.php" {
    deny all;
}
```

### limit_except

```nginx
location / { 
    limit_except GET { 
      allow 192.168.1.0/24; 
      deny all; 
    } 
} 

```

[Top](#top)

## plain

### ansible-playbook in crontab

```plain
*/15 * * * *    if ! out=`ansible-playbook yourplaybook.yaml`; then echo $out; fi

```

[Top](#top)

## powershell

### create a symbolic link in Windows using PowerShell

```powershell
New-Item -ItemType SymbolicLink -Path  "/new/path/to/create/symbolic-link" -Target "/existing/path/to/target/for/symlink"

```

### Get-ComputerInfo

```powershell
Get-ComputerInfo -Property * | convertto-json
```

### get-eventlog

```powershell
get-eventlog -list
```

### list local certificates

```powershell
get-childitem cert:\LocalMachine\My
get-childitem cert:\LocalMachine
get-childitem cert:\LocalMachine\Root | FL *
get-childitem cert:\LocalMachine\"AAD Token Issuer"
get-childitem cert:\LocalMachine\CA

```

### Format-Table -GroupBy - Format processes by BasePriority

```powershell
Get-Process | Sort-Object -Property BasePriority | Format-Table -GroupBy BasePriority -Wrap
```

### Get-ADUser - get last password set for service accounts

```powershell
Get-ADUser -Filter "ownerID -eq 123456 -and employeeType -like 'Service'"  -Properties * | FT  Name,PasswordLastSet
```

### Get-WindowsUpdateLog - get update

```powershell
Get-WindowsUpdateLog 
```

### Finds local admin password and password expiration timestamp for given computer

```powershell
Get-AdmPwdPassword -ComputerName:AT01488YD3 | Format-List *
```

### Get-NetAdapter

```powershell
Get-NetAdapter | Format-Table  -AutoSize -Wrap
```

### Get-WmiObject - get network adapter config

```powershell
Get-WmiObject win32_networkadapterconfiguration | Format-Table DHCPEnabled,ServiceName,Description -AutoSize -Wrap | Format-Wide -Column 3
```

### WindowsIdentity- get current user in powershell

```powershell
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;
$newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";

 echo $myWindowsID
```

### env - get all environment items in powershell

```powershell
Get-ChildItem env:
```

### Get-ADGroupMember

```powershell
Get-ADGroupMember -Identity <Group_Name> 
```

### Powershell - set variables to get dynamic ADUser

```powershell
$Self = Get-ADUser -Identity $Env:Username -Properties *
$EID = $Self.EmployeeId

Get-ADUser  -Filter "OwnerID -like $EID"  -Properties * | sort-object -property PasswordLastSet | Format-Table Name,PasswordLastSet -AutoSize -Wrap
```

### read powershell history and trim leading whitespace

```powershell
POWERSHELL_HISTORY=${USERPROFILE,\\,\/,g}/AppData/Roaming/Microsoft/Windows/PowerShell/PSReadLine/ConsoleHost_history.txt
cat "$POWERSHELL_HISTORY" | sed 's/^[ \t]*//'

```

### get-help - show all loaded cmdlets, functions, and modules in powershell

```powershell
Get-Help Get | Format-Table Name,Category,Module -AutoSize -Wrap
```

### get-adgroup - get all members for AD group

```powershell
get-adgroup -Identity amerunixteam -properties *|Select -ExpandProperty member
```

### get-aduser - get ex employees

```powershell
Get-ADUser -Filter 'Enabled -eq "False"' -Properties * |  Select CN,Description,EmployeeStatus, Country, Department,EmployeeJobDescription | Export-CSV enabled.csv
```

### List available powershell commands

```powershell
gcm -module DISM
```

### Get-WmiObject - get computer system properties

```powershell
Get-WmiObject -Class Win32_ComputerSystem -Property *
```

### Get AD User from another domain (ldap)

```powershell
Get-ADUser -Server amer.example.com -Identity annie_tran -Properties *
```

### get AD domain controller (amer.example.com)

```powershell
Get-ADDomainController
```

### get laptop service tag

```powershell
Get-WmiObject win32_SystemEnclosure | select serialnumber

# another way:
Get-WMIObject -Class Win32_Bios
```

### Get all powershell modules

```powershell
get-module -listavailable
```

### Get group members

```powershell
Get-ADGroupMember -Identity "dbsecuritygroup" -Recursive
```

### get all service accounts owned by user

```powershell
Get-ADUser -Filter "employeeType -eq 'Service' -and OwnerID -eq 873846" -Properties * | FT Name,PasswordLastSet
```

### Get services with search string

```powershell
Get-Service -Displayname "*network*"

Get-Service | Where-Object {$_.Status -eq "Running"}

```

### get all available data about a process

```powershell
Get-Process atom | Format-List *
```

### get ldap group related to ADUser

```powershell
Get-ADUser -Identity Annie_Tran -Properties * | Select -ExpandProperty MemberOf
```

### get AD User (powershell)

```powershell
Get-ADUser -Identity Annie_Tran -Properties *
```

[Top](#top)

## python

### token_hex & token_urlsafe secrets password generator

```python
python -c 'import secrets;print(secrets.token_hex(32))'

python -c 'import secrets;print(secrets.token_urlsafe(32))'
```

### python one liner - return hashed password as a string

```python
python -c 'import crypt; print(crypt.crypt("This is my Password", "$1$SomeSalt$"))'
```

### python oneliner cryptogen

```python
python3 -c "import crypt; print(crypt.crypt(input('clear-text password: '), crypt.mksalt(crypt.METHOD_SHA512)))"
```

### python - select keys in json to print

```python
curl -s "https://jsonplaceholder.typicode.com/posts" | python3 -c "import sys, json; data=json.load(sys.stdin); x = [{'id': d['id'], 'title': d['title']} for d in data]; print(json.dumps(x, indent=2))"
```

### python module calendar

```python
python -m calendar
```

### sysconfig - provide access to Python’s configuration information

```python
python -m sysconfig
```

### cProfile - Performance Profiling Python One-Liner

```python
python -m cProfile file.py

python -m profile file.py
```

### python - csv to json

```python
CSV_FILE=https://raw.githubusercontent.com/jhsu98/json-csv-converter/master/MOCK_DATA.csv

# print each row as an object
curl -s $CSV_FILE |
  python -c "import sys,csv,json;print(json.dumps(list(csv.DictReader(sys.stdin))))"

# print each row as an array
curl -s $CSV_FILE |
  python -c "import sys,csv,json;print(json.dumps(list(csv.reader(sys.stdin))))"
```

### python oneliner - print columns like awk

```python
python3 -c 'print("\n".join(line.split(":",1)[0] for line in open("/etc/passwd")))'
```

### convert json to yaml from stdin

```python
python3 -c "import yaml, json, sys; sys.stdout.write(yaml.dump(json.load(sys.stdin)))"
```

### venv

```python
python -m venv .venv
source .venv/bin/activate
```

### Start a static HTTP server

```python
python -m SimpleHTTPServer 8080
```

### awx-manage shell_plus

```python
from awx.main.utils import decrypt_field

cred_names=["ad-svc-mongodb-nonprod","ad-svc-mongodb-prod","ad-svc-oracle-nonprod","ad-svc-oracle-prod","ad-svc-postgres-nonprod","ad-svc-postgres-prod","ad-svc-sql-nonprod","ad-svc-sql-prod"]

for svc in cred_names:
    cred = Credential.objects.get(name=svc)
    print(svc)
    print(decrypt_field(cred, "password"))

```

[Top](#top)

## sql

### postgres - password md5

```sql
select md5('passwordpostgres');

CREATE USER postgres PASSWORD 'md532e12f215ba27cb750c9e093ce4b5127';

```

### get encrypted password

```sql
select rolname,rolpassword from pg_authid;
          rolname          |             rolpassword
---------------------------+-------------------------------------
 pg_monitor                |
 pg_read_all_settings      |
 pg_read_all_stats         |
 pg_stat_scan_tables       |
 pg_read_server_files      |
 pg_write_server_files     |
 pg_execute_server_program |
 pg_signal_backend         |
 postgres                  | md5XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 pgs_monitor               | md5XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 awx                       | md5XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 awxdbaasusr               | md5XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 hashivaultcicd            | md5XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 rolehashivaultcicd        |
 roledeploymentcicd        |
(15 rows)


```

### awx_postgres - get hostname ids for api

```sql
docker exec -it awx_postgres /bin/bash \
  -c 'psql -t -A -F "," -U awx -d awx -c "select id,name from main_host;"|cat'

psql -t -A -F "," -U awx -d awx -c "select id,name from main_host;"|cat
```

### psql: cast json and pretty print

```sql
select jsonb_pretty(extra_data::jsonb) 
from main_joblaunchconfig where extra_data <> '{}';
```

### postgresql list and order tables by size

```sql
select table_name, pg_size_pretty( pg_relation_size(quote_ident(table_name)) )
from information_schema.tables
where table_schema = 'public'
order by pg_relation_size(quote_ident(table_name)) desc;
```

### get list of tables and number of rows (postgres)

```sql
select n.nspname as table_schema,
       c.relname as table_name,
       c.reltuples as rows
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind = 'r'
      and n.nspname not in ('information_schema','pg_catalog')
order by c.reltuples desc;
```

[Top](#top)

## vim

### vim - display all possible runtime config settings for vim

```vim
:set all
```

[Top](#top)

## yaml

### ansible playbook variables

```yaml
- "{{ var | to_nice_json }}"
- "{{ var | to_json }}"
- "{{ var | from_json }}"
- "{{ var | to_nice_yml }}"
- "{{ var | to_yml }}"
- "{{ var | from_yml }}"
- "{{ result | failed }}"
- "{{ result | changed }}"
- "{{ result | success }}"
- "{{ result | skipped }}"
- "{{ var | manditory }}"
- "{{ var | default(5) }}"
- "{{ list1 | unique }}"
- "{{ list1 | union(list2) }}"
- "{{ list1 | intersect(list2) }}"
- "{{ list1 | difference(list2) }}"
- "{{ list1 | symmetric_difference(list2) }}"
- "{{ ver1 | version_compare(ver2, operator='>=', strict=True) }}"
- "{{ list | random }}"
- "{{ number | random }}"
- "{{ number | random(start=1, step=10) }}"
- "{{ list | join(' ') }}"
- "{{ path | basename }}"
- "{{ path | dirname }}"
- "{{ path | expanduser }}"
- "{{ path | realpath }}"
- "{{ var | b64decode }}"
- "{{ var | b64encode }}"
- "{{ filename | md5 }}"
- "{{ var | bool }}"
- "{{ var | int }}"
- "{{ var | quote }}"
- "{{ var | md5 }}"
- "{{ var | fileglob }}"
- "{{ var | match }}"
- "{{ var | search }}"
- "{{ var | regex }}"
- "{{ var | regexp_replace('from', 'to' ) }}"
```

[Top](#top)
