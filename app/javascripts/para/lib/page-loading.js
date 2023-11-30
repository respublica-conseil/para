Para.PageLoading = class PageLoading {
  constructor() {
    this.start = this.start.bind(this);
    this.stop = this.stop.bind(this);
  }

  start() {
    return this.addLoadingMarkup();
  }

  stop() {
    return this.removeLoadingMarkup();
  }

  addLoadingMarkup() {
    $('<div/>', {
      class: 'loading-overlay',
      'data-loading-overlay': true
    }).prependTo('body');
    
    $('<div/>', {
      class: 'loading-spinner',
      'data-loading-spinner': true
    }).prependTo('body');
  }

  removeLoadingMarkup() {
    $('[data-loading-overlay]').remove();
    return $('[data-loading-spinner]').remove();
  }

};

// Global loading manager allowing to
Para.loadingManager = new Para.PageLoading();

$(document).on('turbo:before-fetch-request', Para.loadingManager.start);

$(document).on('turbo:load turbo:frame-load turbo:before-stream-render turbo:frame-missing turbo:fetch-request-error', function() {
  Para.loadingManager.stop();
  return $('body').on('submit', '[data-para-form]:not([data-remote])', Para.loadingManager.start);
});
