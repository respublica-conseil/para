import { Controller } from "@hotwired/stimulus";
import Selectize from '@selectize/selectize';

export default class extends Controller {
  static values = {
    "input": Array,
    "creatable": Boolean,
    "multi": Boolean,
    "addTranslation": String,
    "collection": Array,
    "max-items": Number,
    "sort-field": String,
    "search-url": String,
    "search-param": String,
    "escape": Boolean
  };

  static targets = [];

  connect() {
    if (this.element.selectize) return;

    // Clean previously initialized selectize DOM elements if any
    if (this.element.nextSibling?.classList?.contains('selectize')) {
      this.element.nextSibling.remove();
    }

    this.load = this.load.bind(this);

    this.isSingle = !this.multiValue;

    this.$el = $(this.element);
    this.$el.selectize(this.options);

    if (this.inputValue) this.initializeValue(this.inputValue);
  }

  get options() {
    return {
      mode: this.isSingle ? 'single' : 'multi',
      maxItems: this.isSingle ? 1 : this.maxItemsValue,
      sortField: this.sortFieldValue,
      plugins: ['remove_button', 'clear_button'],
      create: this.creatableValue,
      render: this.renderOptions,
      options: this.collectionValue,
      load: this.load
    };
  }

  initializeValue(options) {
    if (this.isSingle) {
      this.addAndSelect(options[0]);
    } else {
      options.forEach(option => this.addAndSelect(option));
    }
  }

  addAndSelect(option) {
    this.element.selectize.addOption(option);
    return this.element.selectize.addItem(option.value);
  }

  load(query, callback) {
    var data;
    
    if (!(query.length && this.searchUrlValue)) {
      return callback();
    }

    data = {};
    data[this.searchParamValue] = query;
    
    return $.ajax({
      url: this.searchUrlValue,
      type: 'GET',
      data: data,
      error: callback,
      success: callback
    });
  }

  get renderOptions() {
    return {
      option: (data, escape) => {
        return `
          <div data-value="${escape(data.value)}" class="item">
            ${(this.escapeValue ? escape(data.text) : data.text)}
          </div>
        `;
      },
      item: (data, escape) => {
        return `
          <div data-value="${escape(data.value)}" data-selectable="" class="option">
            ${(this.escapeValue ? escape(data.text) : data.text)}
          </div>
        `;
      },
      option_create: (data) => {
        return `
          <div class="create" data-selectable="">
            ${this.addTranslationValue}
            <strong>${data.input}</strong> ...
          </div>
        `;
      }
    };
  }
}

// Fix for allowEmptyOption issue

// See : https://github.com/selectize/selectize.js/issues/967

hash_key = function(value) {
  if (typeof value === 'undefined' || value === null) {
    return null;
  }
  if (typeof value === 'boolean') {
    if (value) {
      return '1';
    } else {
      return '0';
    }
  }
  return value + '';
};

$.extend(Selectize.prototype, {
  registerOption: function(data) {
    var key;
    key = hash_key(data[this.settings.valueField]);
    // Line 1187 of src/selectize.js should be changed
    // if (!key || this.options.hasOwnProperty(key)) return false;
    if (typeof key === 'undefined' || key === null || this.options.hasOwnProperty(key)) {
      return false;
    }
    data.$order = data.$order || ++this.order;
    this.options[key] = data;
    return key;
  }
});
