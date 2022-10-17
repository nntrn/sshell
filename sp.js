function replaceSensitive(str) {
  const s = typeof str === 'object' ? JSON.stringify(str) : str

  return JSON.parse(
    s
      .replace(/dell([^a-zA-Z\s])/gi, 'example$1')
      .replace(/dell(\s)?([a-zA-Z])/gi, '$2')
      .replace(/873846/g, '123456')
      .replace(/dbaas/g, 'db')
      .replace(/awxpl[a-z]+/g, 'awxserver')
  )
}

function replaceSensitive2(str) {
  const s = typeof str === 'object' ? JSON.stringify(str) : str

  return JSON.parse(
    s
      .replace(/dell([^a-zA-Z\s])/gi, 'example$1')
      .replace(/dell(\s)?([a-zA-Z])/gi, '$2')
      .replace(/873846/g, '123456')
      .replace(/dbaas/g, 'db')
      .replace(/awxpl[a-z]+/g, 'awxserver')
  )
}

const combine = (keys, dict) =>
  keys
    .map((e) => ({ [e]: dict[e] ? dict[e].split('\n') : '' }))
    .reduce((a, b) => Object.assign(a, b), {})

function spCallback(response) {
  const ml = ['code', 'example', 'output', 'code', 'description']

  const defaultUrl = {
    url: {
      Url: '',
    },
  }

  return response.map((data) => ({
    id: data.Id,
    title: data.Title,
    created: data.Created,
    modified: data.Modified,
    ...combine(ml, {
      ...data,
      code: data.cli,
    }),
    language: data.language,
    tags: data.tags || [],
    url: Object.assign({}, defaultUrl, data.url).Url,
  }))
}

SP_API_URL =
  "https://dell-my.sharepoint.com/personal/annie_tran_dell_com/_api/web/lists/GetByTitle('cli')/items?%24top=1000&%24select=ID,Title,cli,language,Created,Modified,example,description,url,tags&%24orderby=%20Created%20desc"

var HTTP_HEADER = {
  headers: {
    accept: 'application/json;odata=nometadata',
  },
  referrerPolicy: 'strict-origin-when-cross-origin',
  method: 'GET',
}

var META_JSON = 'https://raw.githubusercontent.com/nntrn/sshell/data/meta.json'

function escapeHtml(s) {
  var ENTITY_MAP = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
    '/': '&#x2F;',
  }
  return ('' + s).replace(/[&<>"'/]/g, function (s) {
    return ENTITY_MAP[s]
  })
}

function downloadJSON(obj, name = 'snippets') {
  var data = 'text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(obj, null, 2))
  var a = Object.assign(document.createElement('a'), {
    href: 'data:' + data,
    download: `${name}.json`,
    textContent: `download ${name}`,
  })
  a.style.cssText = 'padding:.4em .35em;background:#222;color:#fff'
  document.querySelector('nav').appendChild(a)
  // a.click()
  // a.remove()
  return obj
}

fetch(SP_API_URL, HTTP_HEADER)
  .then((e) => e.json())
  .then((json) => replaceSensitive(json))
  .then((res) => {
    return res.value
  })
  .then((response) => spCallback(response))
  .then((res) => {
    document.body.innerHTML = [
      "<div style='display:flex;height:100%;flex-direction:column'>",
      '<nav></nav>',
      '<pre>',
      escapeHtml(JSON.stringify(res, null, 2)),
      '</pre></div>',
    ].join('\n')
    return res
  })
  .then((resp) =>
    downloadJSON(
      resp,
      ['snippets', new Date().toISOString().replace(/[:.]/g, '-')].join('-')
    )
  )
