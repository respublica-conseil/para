var ref,
  boundMethodCheck = function(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new Error('Bound instance method accessed before binding'); } };

ref = Para.AsyncProgress = class AsyncProgress extends Vertebra.View {
  initialize(options) {
    this.trackProgress = this.trackProgress.bind(this);
    this.onTrackingDataReceived = this.onTrackingDataReceived.bind(this);
    this.onJobError = this.onJobError.bind(this);
    
    this.targetUrl = options.progressUrl || this.$el.data('async-progress-url');
    this.$progressBar = this.$el.find('.progress-bar');
    return this.trackProgress();
  }

  trackProgress() {
    boundMethodCheck(this, ref);
    return $.get(this.targetUrl).done(this.onTrackingDataReceived).fail(this.onJobError);
  }

  stop() {
    return clearTimeout(this.progressTimeout);
  }

  onTrackingDataReceived(data) {
    boundMethodCheck(this, ref);
    if (data.status === 'completed') {
      return this.completed();
    } else {
      return this.setProgress(data.progress);
    }
  }

  setProgress(progress) {
    this.$progressBar.css({
      width: `${progress}%`
    });
    this.progressTimeout = setTimeout(this.trackProgress, 1500);
    return this.trigger('progress');
  }

  completed() {
    this.$progressBar.css({
      width: "100%"
    });
    this.$progressBar.removeClass('progress-bar-striped').addClass('progress-bar-success');
    return this.trigger('completed');
  }

  onJobError() {
    boundMethodCheck(this, ref);
    this.$progressBar.css({
      width: "100%"
    });
    this.$progressBar.removeClass('progress-bar-striped').addClass('progress-bar-error');
    return this.trigger('failed');
  }

};
