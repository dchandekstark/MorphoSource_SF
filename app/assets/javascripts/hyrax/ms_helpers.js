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

  $(document).on("click", this_btn, function() {			
		$(this_div).show();
		$(this_div).addClass('ui-loading');
		$.ajax({
		  url: this_path,
		  success: function(result) {
		  	try {
			    $(this_div).html(result);
		  	} catch (e) {
		  		// catching the error " incorrect module build, no module name "
		  		// todo: resolve the error later
		  		// console.log(e);
		  	}
		  	$(this_div).removeClass('ui-loading');
		  }
		});
	});

  $(this_div).on("submit", this_form, function() {
		$(this_div).hide();
   	$(this_div).html('');
		return true;
  });
  $(this_div).on("click", "button.cancel", function() {
		$(this_div).hide();
   	$(this_div).html('');
  });
}
