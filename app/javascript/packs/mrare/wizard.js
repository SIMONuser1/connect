//
//
// wizard.js
//
// initialises the jQuery Smart Wizard plugin
import smartWizard from 'smartwizard'

$(document).ready(() => {
  $('.wizard').smartWizard({
    transitionEffect: 'fade',
    showStepURLhash: false,
    toolbarSettings: { toolbarPosition: 'none' },
  });
});

