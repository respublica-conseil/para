import { Application } from "@hotwired/stimulus";

function startStimulusApplication() {
  if (window.Stimulus) return window.Stimulus;
  
  const application = Application.start();

  // Configure Stimulus development experience
  application.debug = false;
  window.Stimulus = application;

  return application;
}

const application = startStimulusApplication();

export { application };
