const $$ = (query) => Array.from(document.querySelectorAll(query))
const $ = (query) => document.querySelector(query)

const SNIPPETS_URL = "https://raw.githubusercontent.com/nntrn/sshell/data/data.json"

const urlquery = (query = location.search) =>
  Object.fromEntries(query.split(/[?&]/).filter(Boolean).map((e) => e.split("=")))

const urlparse = (obj) => "?" +
  Object.entries(obj).map((e) => `${e[0]}=${e[1].replace(/ /g, '%20')}`).join("&")

function replaceLocation(obj) {
  const parse = urlparse(Object.assign(urlquery(), obj))
  history.pushState(obj, "", parse)
}

const color = {
  bash: "dodgerblue",
  python: "goldenrod",
  powershell: "tomato",
  cmd: "blueviolet",
  sql: "green",
  javascript: "darkorange",
}

const langLabelStyle = ({ language, level = 600, attr = "background" }) => `${attr}: var(--tw-${color[language] || "shark"}-${level});`

const entity_escape = (s) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;", "/": "&#x2F;" }[s])

const escapeHtml = (str = "") => str.replace(/[&<>"'/]/g, entity_escape)

const fmtPre = (arr = []) =>
  arr.length > 0
    ? escapeHtml(
      [arr]
        .flat(2)
        .map((e) => fmtArraysToText(e))
        .join("\n")
        .replace(/([\r\n])+/g, "\n")
    )
    : ""

function fmtArraysToText(arr = []) {
  if (Array.isArray(arr) && arr.length > 0) {
    while (
      [arr]
        .flat(2)
        .slice(-1)[0]
        .trim()
        .replace(/[\t\r\n]/g, "").length === 0
    ) {
      arr.pop()
    }
  }
  return arr
}


function buildSnippetHtml(json) {

  const expandBlock = ["code", "description", "example", "output"]
    .filter((e) => Boolean(json[e]) && json[e].length > 0)
    .map(e => {
      const typeBlock = ['code', 'example', 'output'].indexOf(e) > -1 ? "pre" : "div"
      return `<${typeBlock} data-section="${e}">${fmtPre(json[e])}</${typeBlock}>`
    })

  return `
  <div class="subtitle">
  <a href="#${json.id}">#${json.id}</a>
  <h3>${json.title.trim()}</h3>
  </div>
  <div class="search-body">
    ${expandBlock.join("\n")}
    ${json.url ? `<div data-section="url"><a href="${json.url}" class="source-link">${json.url}</a></div>` : ""}
  </div>`
}


//function replaceAll(string, map) {
//  for(key in map) {
//      string = string.replace("$" + key, map[key]);
//  }
//  return string;
//}

//var string = '<div><span class="person $type">$name</span><span class="time">$date</span></div>';
//var html = replaceAll(string, {
//  type: personClass,
//  name: personName,
//  date: date
//});

function build(json) {
  const groups = {}

  json.forEach((item) => {
    const re = RegExp(`^${item.language}[\\s-]+`, "ig")
    const title = item.title.replace(re, "").trim()

    if (!groups[item.language]) {
      const detailsBlock = Object.assign(document.createElement("details"), {
        className: item.language,
        innerHTML: `<summary>${item.language}</summary><ul></ul>`,
      })

      $("#sidebar .toc").appendChild(detailsBlock)
      groups[item.language] = detailsBlock.querySelector("ul")
    }

    groups[item.language].appendChild(
      Object.assign(document.createElement("li"), {
        className: "item",
        id: `list-${item.id}`,
        innerHTML: `<a href="#${item.id}">${title}</a>`,
      })
    )

    const contentItem = Object.assign(document.createElement("div"), {
      className: `item ${item.language}`,
      id: `item-${item.id}`,
      innerHTML: buildSnippetHtml(item),
    })

    $("#content").appendChild(contentItem)
  })
}

function setSidebar() {
  $$("#sidebar details").forEach((e) => {
    let count = Array.from(e.querySelectorAll("li:not(.hidden)")).length
    e.dataset.count = count
    if (count && $("#searchbar").value) {
      e.open = true
    } else {
      e.open = false
    }
  })
}

function searchItems(string) {
  if (!$("#searchbar").value) {
    $("#searchbar").value = string
  }
  const searchList = string.split(" ")

  Array.from(document.querySelectorAll("#content .item")).forEach((el) => {
    const searchable = Array.from(el.querySelectorAll("h3,pre"))
      .map((e) => e.textContent)
      .join("\n")
    var results = searchList.filter((s) => searchable.indexOf(s) > -1)
    let sidebarItem = document.getElementById(el.id.replace("item", "list"))

    if (results.length === searchList.length) {
      el.classList.remove("hidden")
      sidebarItem.classList.remove("hidden")
    } else {
      el.classList.add("hidden")
      sidebarItem.classList.add("hidden")
    }
  })
  document.querySelector("#top").scrollIntoView({ behavior: "smooth" })
}

function unhideAllItems() {
  $$("#content .item.hidden").forEach((e) => e.classList.remove("hidden"))
  $$("#sidebar .item.hidden").forEach((e) => e.classList.remove("hidden"))
  setSidebar()
}

function eventFilter(e) {
  const keycodes = {
    enter: 13,
    space: 32,
    //backspace: 8,
    escape: 27,
  }
  if (Object.values(keycodes).includes(e.keyCode)) {
    if (e.keyCode === keycodes.escape) {
      unhideAllItems()
    } else {
      if (e.keyCode === keycodes.enter) {
        history.pushState({}, null, `${location.href.replace(/[#\?].*$/, "")}?search=${e.target.value}`)
      }
      searchItems(e.target.value)
      setSidebar()
    }
  }
}

function toggleTheme() {
  const currentTheme=document.querySelector('body').dataset.theme || ""
  document.querySelector('body').dataset.theme = currentTheme== "light" ? "dark" : "light"
}

function jumpToLocation() {
  const loc = location.hash.slice(1) ? `#item-${location.hash.slice(1)}` : "#top"
  if (location.hash.slice(1)) {
    //document.querySelector("#searchbar").value = ""
    document.querySelector("#searchbar").click()
  }
  if (document.querySelector(`${loc} details`)) {
    document.querySelector(`${loc} details`).open = true
  }
  if (location.hash.slice(1)) {
    const newUrl = location.href.replace(location.search, "")
    history.pushState({}, null, newUrl)
  }
  document.querySelector(loc).scrollIntoView({ behavior: "smooth" })
}

document.querySelector("#searchbar").addEventListener("keyup", eventFilter)

window.addEventListener("load", function () {
  const styleColors = Object.assign(document.createElement('style'), {
    textContent: Object.entries(color).map(c => `.${c[0]}{--color:${c[1]}}`).join("\n")
  })

  document.head.appendChild(styleColors)

  fetch(SNIPPETS_URL)
    .then((e) => e.json())
    .then((res) => build(res))
    .then((e) => {
      if (location.search) {
        const { search, language } = urlquery()
        if (search) {
          searchItems(search)
          setSidebar()
        }
      }
      if (location.hash.slice(1)) {
        document.querySelector("#item-" + location.hash.slice(1)).scrollIntoView({ behavior: "smooth" })
      }
    })
    .catch((err) => console.log(err))
})

window.addEventListener("hashchange", jumpToLocation, false)
