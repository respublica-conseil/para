function trackProgressFor(element, jobStatusUrl) {
  var progressBar = element.querySelector('[data-async-progress]');
  if (!progressBar) return;
  
  var progress = new Para.AsyncProgress({ el: progressBar, progressUrl: jobStatusUrl });

  function handleComplete() {
    $(element).modal('hide');

    var parentFrame = element.parentNode;
    
    parentFrame.addEventListener('turbo:frame-render', function() {
      parentFrame.dispatchEvent(new Event('job:progress:complete'));
    });

    parentFrame.src = jobStatusUrl;

  };

  progress.on('completed', handleComplete);
  progress.on('failed', handleComplete);
}

document.documentElement.addEventListener('turbo:frame-load', function(e) {
  if (e.target.id !== 'para_admin_modal') return;

  loadedElement = e.target.childNodes[0];

  var jobStatusUrl = loadedElement?.dataset?.jobStatusUrl;
  if (!jobStatusUrl) return;

  trackProgressFor(loadedElement, jobStatusUrl);
});
