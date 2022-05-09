# sshell

[nntrn.github.io/sshell](http://nntrn.github.io/sshell)

## Download

```sh
git clone https://github.com/nntrn/sshell.git
cd sshell
```

## Local serve

```sh
# python2
cd public && python2 -m SimpleHTTPServer 3000

# python3
python3 -m http.server --directory public 3000

# php
php -S localhost:3000 -t public/

# serve (npm install -g serve)
serve public
```

## Scripts
```sh
# update snippets.json in data branch
cat updated-snippets.json | ./scripts/update-snippets.sh

# publish changes in public/* to gh-pages branch
./scripts/publish
```