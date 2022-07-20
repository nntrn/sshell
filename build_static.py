#!/usr/bin/env python3

import json
import os
import sys

from jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader('./templates'))
code_tmpl = env.get_template('code_block.txt')
html_tmpl = env.get_template('index.html.j2')
redirect_tmpl = env.get_template('redirect.j2')

all_snippets_html=''

os.makedirs("public/api/", exist_ok=True)

snippets=json.load(sys.stdin)
sorted_snippets = snippets.sort(key=lambda x: x["created"],reverse=True)

for snippet in snippets:
  all_snippets_html += code_tmpl.render(snippet)
  apipath = 'public/api/' + snippet['id']
  filepath = apipath + '.json'

  jsonstring=json.dumps(snippet,ensure_ascii=False,indent=2,sort_keys=False)

  os.makedirs(apipath , exist_ok=True)

  with open( apipath + '.json', 'w') as f:
    f.write(jsonstring)

  with open(apipath + '/index.html', 'w') as f:
    f.write(redirect_tmpl.render(id=snippet['id'],jsonstring=jsonstring))

with open('public/index.html', 'w') as f:
  f.write(html_tmpl.render(snippets=all_snippets_html))
