#!/usr/bin/env python3

from jinja2 import Environment, FileSystemLoader
import json
import os
import sys

env = Environment(loader=FileSystemLoader('./templates'))
code_tmpl = env.get_template('code_block.txt')
html_tmpl = env.get_template('index.html.j2')

all_snippets_html=''

os.makedirs("public/api/", exist_ok=True)

snippets=json.load(sys.stdin)

for snippet in snippets:
  all_snippets_html += code_tmpl.render(snippet)
  filepath = 'public/api/' + snippet['id'] + '.json'
  jsonstring=json.dumps(snippet,ensure_ascii=False,indent=2,sort_keys=False)

  with open(filepath, 'w') as f:
    f.write(jsonstring)

with open('public/index.html', 'w') as f:
  f.write(html_tmpl.render(snippets=all_snippets_html))
