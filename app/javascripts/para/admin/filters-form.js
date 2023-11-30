function initializeFiltersFormSubmit() {
  setTimeout(function() {   
    document.querySelectorAll('[data-filters-form]').forEach(function(form) {
      $(form).on("change", "input, select, textarea", function() {
        form.requestSubmit();
      });
    });
  }, 0);
}

document.documentElement.addEventListener('turbo:load', initializeFiltersFormSubmit);
document.documentElement.addEventListener('turbo:frame-load', initializeFiltersFormSubmit);
