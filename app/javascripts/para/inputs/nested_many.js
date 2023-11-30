Para.NestedManyField = class NestedManyField {
  constructor($field1) {
    this.stoppingPropagation = this.stoppingPropagation.bind(this);
    this.afterInsertField = this.afterInsertField.bind(this);
    this.beforeRemoveField = this.beforeRemoveField.bind(this);
    // When a sub field is removed, update every sub field position
    this.afterRemoveField = this.afterRemoveField.bind(this);
    this.collapseShown = this.collapseShown.bind(this);
    this.$field = $field1;
    this.$fieldsList = this.$field.find('.fields-list');
    this.initializeOrderable();
    this.initializeCocoon();
    this.$field.on('shown.bs.collapse', this.stoppingPropagation(this.collapseShown));
  }

  initializeOrderable() {
    this.orderable = this.$field.hasClass('orderable');
    if (!this.orderable) {
      return;
    }
    return this.$fieldsList.sortable({
      handle: '.order-anchor',
      animation: 150,
      onUpdate: $.proxy(this.handleOrderingUpdated, this)
    });
  }

  handleOrderingUpdated() {
    var formFields;
    formFields = [];
    return this.$fieldsList.find('.form-fields:visible').each(function(_i, el) {
      var $el, $parent, isNestedField, j, len;
      for (j = 0, len = formFields.length; j < len; j++) {
        $parent = formFields[j];
        isNestedField = $parent.find(el).length;
      }
      if (isNestedField) {
        return;
      }
      $el = $(el);
      $el.find('.resource-position-field:eq(0)').val(formFields.length);
      return formFields.push($el);
    });
  }

  initializeCocoon() {
    this.$fieldsList.on('cocoon:after-insert', this.stoppingPropagation(this.afterInsertField));
    this.$fieldsList.on('cocoon:before-remove', this.stoppingPropagation(this.beforeRemoveField));
    return this.$fieldsList.on('cocoon:after-remove', this.stoppingPropagation(this.afterRemoveField));
  }

  stoppingPropagation(callback) {
    return (e, ...args) => {
      e.stopPropagation();
      return callback(e, ...args);
    };
  }

  afterInsertField(e, $element) {
    var $collapsible;
    if (($collapsible = $element.find('[data-open-on-insert="true"]')).length) {
      this.openInsertedField($collapsible);
    }
    if (this.orderable) {
      this.$fieldsList.sortable('destroy');
      this.initializeOrderable();
      this.handleOrderingUpdated();
    }
    return $element.simpleForm();
  }

  beforeRemoveField(e, $element) {
    var $nextEl;
    $nextEl = $element.next();
    if ($nextEl.is('[data-attributes-mappings]') && !$element.is('[data-persisted]')) {
      // Remove attributes mappings field for new records since it will try to
      // create an empty nested resource otherwise
      return $nextEl.remove();
    }
  }

  afterRemoveField() {
    return this.handleOrderingUpdated();
  }

  openInsertedField($field) {
    var $target;
    $target = $($field.attr('href'));
    return $target.collapse('show');
  }

  collapseShown(e) {
    var $target;
    $target = $(e.target);
    if ($target.is("[data-rendered]") || $target.data("rendered")) {
      return this.initializeCollapseContent($target);
    } else {
      this.loadCollapseContent($target);
      return this.scrollToTarget($target);
    }
  }

  initializeCollapseContent($target) {
    this.scrollToTarget($target);
    return this.focusFirstField($target);
  }

  scrollToTarget($target) {
    var $affixNavTabs, $field, scrollOffset;
    $field = this.$field.find(`[data-toggle='collapse'][href='#${$target.attr('id')}']`);
    scrollOffset = -($('[data-header]').outerHeight() + 30);
    if (($affixNavTabs = $("[data-tabs-nav-affix]:eq(0)")).length) {
      scrollOffset -= $affixNavTabs.outerHeight();
    }
    return $.scrollTo($field, 200, {
      offset: scrollOffset
    });
  }

  focusFirstField($target) {
    return $target.find('input, textarea, select').eq('0').focus();
  }

  loadCollapseContent($target) {
    var data, targetUrl;
    targetUrl = $target.data("render-path");
    if (!targetUrl) {
      return;
    }
    data = {
      "id": $target.data("id"),
      "object_name": $target.data("object-name"),
      "model_name": $target.data("model-name")
    };
    return $.get(targetUrl, data).then((resp) => {
      var $content;
      $content = $(resp);
      $target.find("[data-nested-form-container]:eq(0)").html($content);
      $content.simpleForm();
      this.focusFirstField($target);
      return $target.data("rendered", true);
    });
  }

};

$.simpleForm.onDomReady(function($document) {
  return $document.find('.nested-many-field').each(function(i, el) {
    return new Para.NestedManyField($(el));
  });
});
