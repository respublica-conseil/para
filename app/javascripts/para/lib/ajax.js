Para.ajax = function(options = {}) {
  var csrfOptions, csrfParam, csrfToken;
  csrfParam = $('meta[name="csrf-param"]').attr('content');
  csrfToken = $('meta[name="csrf-token"]').attr('content');
  csrfOptions = {};
  if (csrfParam && csrfToken) {
    csrfOptions[csrfParam] = csrfToken;
  }
  if (!(options.method && options.method.match(/get/i))) {
    options = $.extend(csrfOptions, options);
  }
  return $.ajax(options);
};
