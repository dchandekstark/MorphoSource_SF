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
function setupEmbeddedWorkForm(work_name) {
	var this_btn = "#btn_" + work_name;
	var this_div = "#embedded_div_" + work_name;
	var this_form = "form#" + work_name;
	var this_path = "/submissions/" + work_name;

  $(document).on("click", this_btn, function() {		
  	// load the new work form	
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
		// replace with ajax form post to trigger other actions
		$.post($(this_form).attr('action'),
	  $(this_form).serialize(), function(data, status){
	    console.log('new work created ', data);
			var relationship_element = $(this_div).data("relationship-control");
	  	var relationship_input = $(relationship_element).find('input[name*="[find_parent_work]"]');
			$(relationship_input).val(data.work.id);
			var new_data = {
				id: data.work.id, 
				text: data.work.title
			};
	    $(relationship_element).data('new-work-created', new_data);
			var relationship_add_btn = $(this_div).data("add-button");
			$(relationship_add_btn).trigger("click");

			// perform any work specifc function
			switch(work_name) {
				case 'new_institution':
					$('#biological_specimen_institution_code').val(data.work.institution_code);
					break;
				default:
			}
			$(this_div).hide();
	  });
	  
		$(this_div).addClass('ui-loading');
		//$(this_div).hide();
   	$(this_div).html('');
		return false;
  });
  $(this_div).on("click", "button.cancel", function() {
		$(this_div).hide();
   	$(this_div).html('');
  });
}
