import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {};
  static targets = ["modal"];

  connect() {}

  disconnect() {
    if (this.hasModalTarget) this.modalTarget.remove();
  }

  modalTargetConnected() {
    this.modalTarget.classList.add('in', 'show');
    this.displayBackdrop();
    document.body.classList.add('modal-open');

    $(this.element).simpleForm();
  }

  modalTargetDisconnected() {
    this.closeModal();
  }

  closeModal() {
    document.body.classList.remove('modal-open');

    if (this.hasModalTarget) this.modalTarget.classList.remove('in', 'show');
    this.backdropElement?.remove();
    delete this.backdropElement;
  }

  displayBackdrop() {
    if (this.backdropElement) return;

    this.backdropElement = document.createElement('div');
    this.backdropElement.classList.add(
      'modal-backdrop', 'fade', 'in', 'bg-primary', 'bg-primary-80-desktop'
    );

    this.element.appendChild(this.backdropElement);
  }
}