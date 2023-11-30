$(document).on('page:change turbo:load turbo:frame-load', function() {
  return $('body').on('focusin focusout', 'input, select, textarea', function(e) {
    var focused;
    focused = e.type === 'focusin';
    return $(e.target).closest('.form-group').toggleClass('focused', focused);
  });
});
