# sshell

[nntrn.github.io/sshell](http://nntrn.github.io/sshell)


## Running Locally

```sh
git clone https://github.com/nntrn/sshell.git
cd sshell

# serve locally using python
python3 -m http.server 3000

# serve locally using serve
serve .
```

## Scripts
```sh
# update snippets.json in data branch
cat file.json | ./scripts/update-snippets.sh

# publish changes in public/* to gh-pages branch
./scripts/publish
```