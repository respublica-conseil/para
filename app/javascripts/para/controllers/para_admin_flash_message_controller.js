import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["alert"];

  connect() {
    this.autoCloseTimer = setTimeout(() => this.close(), 10000);
  }

  disconnect() {
    this.cleanTimer();
  }

  close() {
    this.element.classList.remove("in");
  }

  cleanTimer() {
    if (this.autoCloseTimer) {
      clearTimeout(this.autoCloseTimer);
    }
  }
}