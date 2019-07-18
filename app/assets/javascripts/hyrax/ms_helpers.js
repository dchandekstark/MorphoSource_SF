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

// setup embedded work form, when to load the form, submit and close handling
function setupEmbeddedForm(work_name) {
	var this_btn = "#btn_" + work_name;
	var this_div = "#embedded_div_" + work_name;
	var this_form = "form#" + work_name;
	var this_path = "/submissions/" + work_name;


//								var this_path = "tryloadsomethingelse";


  $(document).on("click", this_btn, function() {			
		$(this_div).load(this_path);
		$(this_div).show();
	});

  $(this_div).on("submit", this_form, function() {
		$(this_div).hide();
		return true;
  });
  $(this_div).on("click", "button.cancel", function() {
		$(this_div).hide();
  });
}

		setupEmbeddedForm('new_taxonomy');
		setupEmbeddedForm('new_institution');
