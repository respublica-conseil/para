var ref, ref1,
  boundMethodCheck = function(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new Error('Bound instance method accessed before binding'); } };

ref = Para.MultiSelectInput = (function() {
  class MultiSelectInput extends Vertebra.View {
    initialize() {
      this.triggerSearch = this.triggerSearch.bind(this);
      this.onSearchReturn = this.onSearchReturn.bind(this);
      this.onItemAdded = this.onItemAdded.bind(this);
      this.onItemRemoved = this.onItemRemoved.bind(this);
      this.selectedItemsSorted = this.selectedItemsSorted.bind(this);
      
      var el;
      this.$searchField = this.$('[data-search-field]');
      this.$selectedItems = this.$('[data-selected-items] tbody');
      this.$availableItems = this.$('[data-available-items]');
      this.$input = this.$('[data-multi-select-input-field]');
      this.searchURL = this.$el.data('search-url');
      this.orderable = this.$el.is('[data-orderable]');
      this.searchParam = this.$searchField.attr('name');
      this.noSelectedItemsTemplate = this.$('[data-no-selected-items]').data('no-selected-items');
      this.noAvailableItemsTemplate = this.$('[data-no-available-items]').data('no-available-items');
      this.throttledTriggerSearch = throttle(this.triggerSearch, 300, {
        trailing: true
      });
      this.availableItems = [];
      this.selectedItems = (function() {
        var j, len, ref1, results1;
        ref1 = this.$selectedItems.find('[data-selected-item-id]');
        results1 = [];
        for (j = 0, len = ref1.length; j < len; j++) {
          el = ref1[j];
          results1.push(this.buildSelectedItem(el));
        }
        return results1;
      }).call(this);
      this.refreshSelectedItems();
      return this.refreshAvailableItems();
    }

    onSearchKeyUp() {
      return this.throttledTriggerSearch();
    }

    triggerSearch() {
      boundMethodCheck(this, ref);
      return this.searchFor(this.$searchField.val());
    }

    searchFor(terms) {
      var data, ref1;
      terms = trim(terms);
      if (terms === this.terms || (!terms && !this.terms)) {
        return;
      }
      this.terms = terms;
      this.setLoading(true);
      if ((ref1 = this._currentSearchXHR) != null) {
        ref1.abort();
      }
      data = this.$('[data-search-field-input]').serialize();
      return this._currentSearchXHR = $.get(this.searchURL, data).done(this.onSearchReturn);
    }

    onSearchReturn(results) {
      boundMethodCheck(this, ref);
      this._currentSearchXHR = null;
      this.setLoading(false);
      this.$('[data-available-items] tbody').html(results);
      return this.refreshAvailableItems();
    }

    refreshAvailableItems() {
      var el, item, j, len, ref1;
      ref1 = this.availableItems;
      for (j = 0, len = ref1.length; j < len; j++) {
        item = ref1[j];
        item.destroy();
      }
      this.availableItems = (function() {
        var k, len1, ref2, results1;
        ref2 = this.$('[data-available-items] tr');
        results1 = [];
        for (k = 0, len1 = ref2.length; k < len1; k++) {
          el = ref2[k];
          results1.push(this.buildAvailableItem(el));
        }
        return results1;
      }).call(this);
      if (!this.availableItems.length) {
        return this.showEmptyListHint(this.noAvailableItemsTemplate, this.$availableItems);
      }
    }

    buildAvailableItem(el) {
      var availableItem, j, len, ref1, selectedItem;
      availableItem = new Para.MultiSelectAvailableItem({
        el: el
      });
      ref1 = this.selectedItems;
      for (j = 0, len = ref1.length; j < len; j++) {
        selectedItem = ref1[j];
        if (selectedItem.id === availableItem.id) {
          availableItem.setSelected(true);
        }
      }
      this.listenTo(availableItem, 'add', this.onItemAdded);
      return availableItem;
    }

    onItemAdded(item) {
      boundMethodCheck(this, ref);
      return this.selectItem(item);
    }

    buildSelectedItem(el) {
      var selectedItem;
      selectedItem = new Para.MultiSelectSelectedItem({
        el: el
      });
      this.listenTo(selectedItem, 'remove', this.onItemRemoved);
      return selectedItem;
    }

    selectItem(item) {
      var selectedItem;
      if (this.alreadySelected(item)) {
        return;
      }
      item.setSelected(true);
      selectedItem = this.buildSelectedItem(item.$el.attr('data-selected-item-template'));
      this.selectedItems.push(selectedItem);
      return this.refreshSelectedItems();
    }

    alreadySelected(item) {
      var j, len, ref1, selectedItem;
      ref1 = this.selectedItems;
      for (j = 0, len = ref1.length; j < len; j++) {
        selectedItem = ref1[j];
        if (selectedItem.id === item.id) {
          return true;
        }
      }
      return false;
    }

    refreshSelectedItems() {
      var j, len, ref1, selectedItem, selectedItemIds;
      this.$selectedItems.empty();
      ref1 = this.selectedItems;
      for (j = 0, len = ref1.length; j < len; j++) {
        selectedItem = ref1[j];
        selectedItem.renderTo(this.$selectedItems);
      }
      selectedItemIds = ((function() {
        var k, len1, ref2, results1;
        ref2 = this.selectedItems;
        results1 = [];
        for (k = 0, len1 = ref2.length; k < len1; k++) {
          selectedItem = ref2[k];
          results1.push(selectedItem.id);
        }
        return results1;
      }).call(this)).join(', ');
      this.$input.val(selectedItemIds);
      if (this.selectedItems.length) {
        return this.initializeOrderable();
      } else {
        return this.showEmptyListHint(this.noSelectedItemsTemplate, this.$selectedItems);
      }
    }

    showEmptyListHint(template, $container) {
      return $(template).appendTo($container);
    }

    onItemRemoved(selectedItem) {
      var availableItem, index, item, itemIndex, j, k, len, len1, ref1, ref2;
      boundMethodCheck(this, ref);
      ref1 = this.selectedItems;
      for (index = j = 0, len = ref1.length; j < len; index = ++j) {
        item = ref1[index];
        if (item.id === selectedItem.id) {
          itemIndex = index;
        }
      }
      this.selectedItems.splice(itemIndex, 1);
      selectedItem.destroy();
      this.refreshSelectedItems();
      ref2 = this.availableItems;
      for (k = 0, len1 = ref2.length; k < len1; k++) {
        item = ref2[k];
        if (item.id === selectedItem.id) {
          availableItem = item;
        }
      }
      if (availableItem) {
        return availableItem.setSelected(false);
      }
    }

    onAllItemsAdded() {
      var availableItem, j, len, ref1, results1;
      if (!this.availableItems.length) {
        return;
      }
      ref1 = this.availableItems;
      results1 = [];
      for (j = 0, len = ref1.length; j < len; j++) {
        availableItem = ref1[j];
        results1.push(this.selectItem(availableItem));
      }
      return results1;
    }

    onAllItemsRemoved() {
      var item, j, len, ref1, results1;
      if (!this.selectedItems.length) {
        return;
      }
      this.selectedItems = [];
      this.refreshSelectedItems();
      ref1 = this.availableItems;
      results1 = [];
      for (j = 0, len = ref1.length; j < len; j++) {
        item = ref1[j];
        results1.push(item.setSelected(false));
      }
      return results1;
    }

    initializeOrderable() {
      var columnsCount;
      if (!this.orderable) {
        return;
      }
      columnsCount = this.$selectedItems.find('> tr > td').length;
      this.$selectedItems.sortable('destroy');
      this.$selectedItems.sortable({
        handle: '.order-anchor',
        animation: 150
      });
      return this.$selectedItems.on('sort', this.selectedItemsSorted);
    }

    selectedItemsSorted() {
      var el, index, indices, j, len, ref1;
      boundMethodCheck(this, ref);
      indices = {};
      ref1 = this.$selectedItems.find('[data-selected-item-id]');
      for (index = j = 0, len = ref1.length; j < len; index = ++j) {
        el = ref1[index];
        indices[$(el).data('selected-item-id')] = index;
      }
      this.selectedItems.sort((a, b) => {
        var aIndex, bIndex;
        aIndex = indices[a.id];
        bIndex = indices[b.id];
        if (aIndex > bIndex) {
          return 1;
        } else {
          return -1;
        }
      });
      return this.refreshSelectedItems();
    }

    setLoading(state) {
      this.$el.toggleClass('loading', state);
      return this.$('.fa-search').toggleClass('fa-spin', state);
    }

  };

  MultiSelectInput.prototype.events = {
    'keyup [data-search-field]': 'onSearchKeyUp',
    'click [data-add-all]': 'onAllItemsAdded',
    'click [data-remove-all]': 'onAllItemsRemoved'
  };

  return MultiSelectInput;

}).call(this);

Para.MultiSelectAvailableItem = (function() {
  class MultiSelectAvailableItem extends Vertebra.View {
    initialize() {
      return this.id = this.$el.data('available-item-id');
    }

    addItem() {
      return this.trigger('add', this);
    }

    setSelected(selected) {
      this.selected = selected;
      return this.$el.toggleClass('selected', this.selected);
    }

  };

  MultiSelectAvailableItem.prototype.events = {
    'click [data-add-item]': 'addItem'
  };

  return MultiSelectAvailableItem;

}).call(this);

ref1 = Para.MultiSelectSelectedItem = class MultiSelectSelectedItem extends Vertebra.View {
  constructor() {
    super(...arguments);
    this.removeItem = this.removeItem.bind(this);
  }

  initialize() {
    return this.id = this.$el.data('selected-item-id');
  }

  bindEvents() {
    return this.$('[data-remove-item]').on('click', this.removeItem);
  }

  renderTo($container) {
    this.$el.appendTo($container);
    return this.bindEvents();
  }

  removeItem(e) {
    boundMethodCheck(this, ref1);
    return this.trigger('remove', this);
  }

};

$.simpleForm.onDomReady(function($document) {
  return $document.find('[data-multi-select-input]').each(function(i, el) {
    return new Para.MultiSelectInput({
      el: el
    });
  });
});
