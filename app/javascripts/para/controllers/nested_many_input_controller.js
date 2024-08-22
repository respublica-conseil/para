import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    this.stoppingPropagation = this.stoppingPropagation.bind(this);
    this.afterInsertField = this.afterInsertField.bind(this);
    this.beforeRemoveField = this.beforeRemoveField.bind(this);
    this.handleOrderingUpdated = this.handleOrderingUpdated.bind(this);
    this.afterRemoveField = this.afterRemoveField.bind(this);
    this.collapseShown = this.collapseShown.bind(this);

    this.$field = $(this.element);
    this.$fieldsList = this.$field.find('.fields-list');
    this.initializeSortable();
    this.initializeCocoon();
    this.$field.on('shown.bs.collapse', this.stoppingPropagation(this.collapseShown));
  }

  initializeSortable() {
    this.isSortable = this.$field.hasClass('orderable');

    if (!this.isSortable) return;

    return this.$fieldsList.sortable({
      handle: '.order-anchor',
      animation: 150,
      onUpdate: this.handleOrderingUpdated
    });
  }

  handleOrderingUpdated() {
    var formFields;
    formFields = [];

    return this.$fieldsList.find('.form-fields:visible').each(function(_i, el) {
      let $parent, isNestedField, j, len;

      for (j = 0, len = formFields.length; j < len; j++) {
        $parent = formFields[j];
        isNestedField = $parent.find(el).length;
      }

      if (isNestedField) {
        return;
      }

      const $el = $(el);
      $el.find('.resource-position-field:eq(0)').val(formFields.length);
      return formFields.push($el);
    });
  }

  initializeCocoon() {
    this.$fieldsList.on(
      'cocoon:after-insert', 
      this.stoppingPropagation(this.afterInsertField)
    );

    this.$fieldsList.on(
      'cocoon:before-remove', 
      this.stoppingPropagation(this.beforeRemoveField)
    );

    return this.$fieldsList.on(
      'cocoon:after-remove', 
      this.stoppingPropagation(this.afterRemoveField)
    );
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
    if (this.isSortable) {
      this.$fieldsList.sortable('destroy');
      this.initializeSortable();
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
    const { target } = e;

    if (target.dataset.isRendered) {
      return this.initializeCollapseContent(target);
    } else {
      this.loadCollapseContent(target);
      return this.scrollToTarget(target);
    }
  }

  initializeCollapseContent(target) {
    this.scrollToTarget(target);
    return this.focusFirstVisibleInputInside(target);
  }

  scrollToTarget(target) {
    const $target = $(target);

    var $affixNavTabs, $field, scrollOffset;
    $field = this.$field.find(`[data-toggle='collapse'][href='#${$target.attr('id')}']`);
    scrollOffset = -($('[data-header]').outerHeight() + 30);
    if (($affixNavTabs = $('[data-affix-header="tabs"]:eq(0)')).length) {
      scrollOffset -= $affixNavTabs.outerHeight();
    }
    return $.scrollTo($field, 200, {
      offset: scrollOffset
    });
  }

  focusFirstVisibleInputInside(target) {
    setTimeout(() => {
      target.querySelector('input:not([type="hidden"]), textarea, select')?.focus();
    }, 100);
  }

  loadCollapseContent(target) {
    const $target = $(target);
    const targetUrl = target.dataset.renderPath;

    if (!targetUrl) return;

    const data = {
      id: target.dataset.id,
      object_name: target.dataset.objectName,
      model_name: target.dataset.modelName
    };

    $.get(targetUrl, data).then((resp) => {
      const $content = $(resp);
      $target.find('[data-nested-form-container]:eq(0)').html($content);
      $content.simpleForm();

      this.focusFirstVisibleInputInside(target);
      
      target.dataset.isRendered = true;
    });
  }
};
