class Card {
  constructor(name = 'div', attr = {}) {

    this.root = Object.assign(document.createElement(name), attr)
  }

  getElement() {
    return this.root
  }

  addChild(el = 'div', attr = {}) {
    const childEl = new Card(el, attr)
    this.getElement().appendChild(childEl)
    return childEl
  }

}
