$(document).on('turbolinks:load', function() {
  if ($('form[id*="biological_specimen"]').length) { // if BSO form page
    setupEmbeddedForm('new_taxonomy');
    setupEmbeddedForm('new_institution');
  }
});