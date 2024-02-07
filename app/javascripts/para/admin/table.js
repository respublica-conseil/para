import { PATCH, fetch } from "../lib/fetch";

Para.ResourceTable = class ResourceTable {
  constructor($table) {
    this.$table = $table;
    this.$tbody = this.$table.find('tbody');
    this.initializeOrderable();
  }

  initializeOrderable() {
    this.orderable = this.$table.hasClass('orderable');
    if (!this.orderable) {
      return;
    }
    this.orderUrl = this.$table.data('order-url');
    return this.$tbody.sortable({
      handle: '.order-anchor',
      draggable: 'tr',
      ghostClass: 'sortable-placeholder',
      onUpdate: $.proxy(this.sortUpdate, this)
    });
  }

  sortUpdate() {
    this.$tbody.find('tr').each(function(i, el) {
      return $(el).find('.resource-position-field').val(i);
    });
    return this.updateOrder();
  }

  updateOrder() {
    fetch(this.orderUrl, {
      method: PATCH,
      body: this.buildOrderedData()
    });
  }

  buildOrderedData() {
    const data = new FormData();

    this.$tbody.find('.resource-position-field').each((i, el) => {
      const $field = $(el);
      const resourceKey = `resources[${i}]`;

      data.append(`${resourceKey}[id]`, $field.closest('.order-anchor').data('id'));
      data.append(`${resourceKey}[position]`, $field.val());  
    });

    return data;
  }
};

// TODO: Add flash message to display ordering success
$(document).on('turbo:load turbo:frame-load', function() {
  return $('.para-component-relation-table').each(function(i, el) {
    return new Para.ResourceTable($(el));
  });
});
