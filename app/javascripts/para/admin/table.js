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
    return Para.ajax({
      url: this.orderUrl,
      method: 'patch',
      data: {
        resources: this.buildOrderedData()
      },
      success: $.proxy(this.orderUpdated, this)
    });
  }

  buildOrderedData() {
    var $field, field, i, ref, results;
    ref = this.$tbody.find('.resource-position-field').get();
    results = [];
    for (i in ref) {
      field = ref[i];
      $field = $(field);
      results.push({
        id: $field.closest('.order-anchor').data('id'),
        position: $field.val()
      });
    }
    return results;
  }

  orderUpdated() {}

};

// TODO: Add flash message to display ordering success
$(document).on('turbo:load turbo:frame-load', function() {
  return $('.para-component-relation-table').each(function(i, el) {
    return new Para.ResourceTable($(el));
  });
});
