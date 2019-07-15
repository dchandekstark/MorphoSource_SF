// shared helper functions 

// functions for show/edit fields
function show_fields(field_array) {
  $(field_array.join(',')).removeClass('hide');
}

function hide_fields(field_array, clear = true) {
  $(field_array.join(',')).addClass('hide');
  if (clear) {
    $(field_array.join(',')).children('input, select').val('');
  }
}

// close a modal overlay before submitting the form
function registerModalSubmit(this_modal, this_form) {
  $(this_modal).on("submit", this_form, function() {
		$(this_modal).modal('hide');
		return true;
  });
}
