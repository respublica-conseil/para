var responsive_sidebar_navigation, scrollToComponentSection;

scrollToComponentSection = function($component, duration = 0) {
  var headerHeight, sectionOffset;
  sectionOffset = $component.closest('.component-section-item').offset().top + $('.navmenu').scrollTop();
  headerHeight = $('.navmenu .navmenu-brand').outerHeight();
  return $('.navmenu-nav').scrollTo(sectionOffset - headerHeight, {
    duration: duration
  });
};

responsive_sidebar_navigation = function() {
  var $activeItem;
  // Scroll to active element's section on page change
  if (($activeItem = $('.component-item.active')).length) {
    scrollToComponentSection($activeItem);
  }
  return $('.component-item').on('click', 'a', function(e) {
    return scrollToComponentSection($(e.currentTarget), 150);
  });
};

$(document).on('turbo:load turbo:frame-load', function() {
  responsive_sidebar_navigation();
  return $(".selectize-tags").selectize({
    delimiter: ",",
    persist: false,
    create: function(input) {
      return {
        value: input,
        text: input
      };
    }
  });
});

$(window).resize(function() {
  return responsive_sidebar_navigation();
});
