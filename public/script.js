function getSnippetsUrl() {
  return 'https://raw.githubusercontent.com/nntrn/sshell/data/snippets.json'
}

function removeHash () {
  history.replaceState({}, document.title, window.location.href.split('#')[0]);
}

function groupByKey(obj, key) {
  return obj.reduce((group, product) => {
    const value = product[key]
    group[value] = group[value] ?? []
    group[value].push(product)
    return group
  }, {})
}

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

function buildSnippets(res) {
  Object.entries(groupByKey(res, 'language')).forEach((langGrp) => {
    const group = Object.assign(document.createElement('div'), {
      className: 'group',
      id: langGrp[0],
    })

    const link = Object.assign(document.createElement('a'), {
      className: 'link',
      href: `#${langGrp[0]}`,
      textContent: langGrp[0],
    })

    document.querySelector('#toc').appendChild(link)

    group.dataset.before = langGrp[0]

    langGrp[1].forEach(({ output, ...e }) => {
      const itemjson = JSON.stringify(e, null, 2)
      const codeText = escapeHtml([e.cli].flat(2).join('\n'))
      group.appendChild(
        Object.assign(document.createElement('div'), {
          className: 'item',
          id: `data-${e.id}`,
          innerHTML: [
            `<h4><a href="#${e.id}" onclick="showPopup(${e.id})">${e.title}</a></h4>`,
            `<div class="code" style="white-space:break-spaces;user-select:all">${codeText}</div>`,
            `<div class="filter" style="display:none">${itemjson}</div>`,
          ].join('\n'),
        })
      )
    })
    document.querySelector('#sshell').appendChild(group)
  })
}

function searchItems(string) {
  Array.from(document.querySelectorAll('.item .filter')).forEach((e) => {
    if (e.textContent.includes(string)) {
      e.parentElement.classList.remove('hidden')
    } else {
      e.parentElement.classList.add('hidden')
    }
  })
}

function unhideAllItems(e) {
  console.log(e)
  Array.from(document.querySelectorAll('.item .hidden')).forEach((e) => {
    e.classList.remove('hidden')
  })
}

function eventFilter(e) {
  const keycodes = {
    enter: 13,
    space: 32,
    backspace: 8,
  }
  if (Object.values(keycodes).includes(e.keyCode)) {
    console.log(e.keyCode, e.key)
    const searchString = e.target.value.toLowerCase().trim()
    searchItems(searchString)
  }
}

function hidePopup() {
  document.querySelector('#popup').classList.remove('show')
  Array.from(document.querySelectorAll('#popup [data-key]')).forEach(
    (e) => (e.textContent = '')
  )
  removeHash()
}

function getLocationId() {
  return location.hash.slice(1)
}

function editPopupText(obj) {
  Array.from(document.querySelectorAll('#popup [data-key]')).forEach(
    (e) => (e.textContent = [obj[e.dataset.key]].flat(2).join('\n'))
  )
}

function showPopup(id = getLocationId()) {
  editPopupText(
    JSON.parse(document.querySelector(`#data-${id} .filter`).textContent)
  )
  document.querySelector('#popup').classList.add('show')
}

document
  .querySelector('#searchbar')
  .addEventListener('keyup', eventFilter)

document
  .querySelector('#searchbar')
  .addEventListener('click', unhideAllItems)

document.onkeydown = function (evt) {
  if (evt.keyCode === 27) {
    hidePopup()
  }
}

window.addEventListener('load', function () {
  fetch(getSnippetsUrl())
    .then((e) => e.json())
    .then((res) => buildSnippets(res))
    .then((e) => {
      if (location.hash) {
        showPopup()
      }
    })
    .catch((err) => console.log(err))
})