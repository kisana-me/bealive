import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nav"]

  toggle() {
    this.navTarget.classList.toggle("is-active")
    document.body.classList.toggle("no-scroll")
  }
}
