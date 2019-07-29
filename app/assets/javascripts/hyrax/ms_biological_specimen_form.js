$(document).on('turbolinks:load', function() {
  if ($('form[id*="biological_specimen"]').length) { // if BSO form page
//    setupEmbeddedForm('new_taxonomy');
    setupEmbeddedWorkForm('new_institution');

    $(document).on("click", "#btn-add-institution", function() {
      alert('c');
      // check if an institution exists already
      
      return false;
    });
  }
});