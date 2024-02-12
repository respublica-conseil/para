import { Controller } from "@hotwired/stimulus";

const FLASH_BASE_OFFSET = 10;

export default class extends Controller {
  static targets = ["alert"];

  connect() {
    this.refreshTopOffset = this.refreshTopOffset.bind(this);

    this.autoCloseTimer = setTimeout(() => this.close(), 10000);

    this.refreshTopOffset();
    window.addEventListener("resize", this.refreshTopOffset);

    this.element.classList.add("in");
  }

  disconnect() {
    this.cleanTimer();
    window.removeEventListener("resize", this.refreshTopOffset);
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

  refreshTopOffset() {
    const headerHeight = document.querySelector("[data-header]")?.offsetHeight || 0;
    const affixHeaderHeight = 
      document.querySelector("[data-affix-header]")?.offsetHeight || 0;

    const offsetTop = headerHeight + affixHeaderHeight + FLASH_BASE_OFFSET;
    
    this.element.parentElement.style.top = `${offsetTop}px`;
  }
}