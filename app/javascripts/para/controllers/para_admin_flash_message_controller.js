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
    this.removeTimer = setTimeout(() => this.element.remove(), 500);
  }

  cleanTimer() {
    if (this.autoCloseTimer) {
      clearTimeout(this.autoCloseTimer);
    }

    if (this.removeTimer) {
      clearTimeout(this.removeTimer);
    }
  }
}