class Para.NestedManyField
  constructor: (@$field) ->
    @$fieldsList = @$field.find('.fields-list')

    @initializeOrderable()
    @initializeCocoon()

    @$field.on 'shown.bs.collapse', @stoppingPropagation(@collapseShown)

  initializeOrderable: ->
    @orderable = @$field.hasClass('orderable')
    return unless @orderable

    @$fieldsList.sortable
      handle: '.order-anchor'
      animation: 150
      onUpdate: $.proxy(@handleOrderingUpdated, this)

  handleOrderingUpdated: ->
    formFields = []

    @$fieldsList.find('.form-fields:visible').each (_i, el) ->
      isNestedField = $parent.find(el).length for $parent in formFields
      return if isNestedField

      $el = $(el)
      $el.find('.resource-position-field:eq(0)').val(formFields.length)
      formFields.push($el)

  initializeCocoon: ->
    @$fieldsList.on 'cocoon:after-insert', @stoppingPropagation(@afterInsertField)
    @$fieldsList.on 'cocoon:before-remove', @stoppingPropagation(@beforeRemoveField)
    @$fieldsList.on 'cocoon:after-remove', @stoppingPropagation(@afterRemoveField)

  stoppingPropagation: (callback) =>
    (e, args...) =>
      e.stopPropagation()
      callback(e, args...)

  afterInsertField: (e, $element) =>
    if ($collapsible = $element.find('[data-open-on-insert="true"]')).length
      @openInsertedField($collapsible)

    if @orderable
      @$fieldsList.sortable('destroy')
      @initializeOrderable()
      @handleOrderingUpdated()

    $element.simpleForm()

  beforeRemoveField: (e, $element) =>
    $nextEl = $element.next()
    # Remove attributes mappings field for new records since it will try to
    # create an empty nested resource otherwise
    $nextEl.remove() if $nextEl.is('[data-attributes-mappings]') and not $element.is('[data-persisted]')

  # When a sub field is removed, update every sub field position
  afterRemoveField: =>
    @handleOrderingUpdated();

  openInsertedField: ($field) ->
    $target = $($field.attr('href'))
    $target.collapse('show')

  collapseShown: (e) =>
    $target = $(e.target)

    if $target.is("[data-rendered]") or $target.data("rendered")
      @initializeCollapseContent($target)
    else
      @loadCollapseContent($target)
      @scrollToTarget($target)

  initializeCollapseContent: ($target) ->
    @scrollToTarget($target)
    @focusFirstField($target)

  scrollToTarget: ($target) ->
    $field = @$field.find("[data-toggle='collapse'][href='##{ $target.attr('id') }']")
    scrollOffset = -($('[data-header]').outerHeight() + 30)

    if ($affixNavTabs = $("[data-tabs-nav-affix]:eq(0)")).length
      scrollOffset -= $affixNavTabs.outerHeight()

    $.scrollTo($field, 200, offset: scrollOffset)

  focusFirstField: ($target) ->
    $target.find('input, textarea, select').eq('0').focus()

  loadCollapseContent: ($target) ->
    targetUrl = $target.data("render-path")
    return unless targetUrl

    data = {
      "id": $target.data("id")
      "object_name": $target.data("object-name")
      "model_name": $target.data("model-name")
    }

    $.get(targetUrl, data).then (resp) =>
      $content = $(resp)
      $target.find("[data-nested-form-container]:eq(0)").html($content)
      $content.simpleForm()
      @focusFirstField($target)
      $target.data("rendered", true)

$.simpleForm.onDomReady ($document) ->
  $document.find('.nested-many-field').each (i, el) -> new Para.NestedManyField($(el))
