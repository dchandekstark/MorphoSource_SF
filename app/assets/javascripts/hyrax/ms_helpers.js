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
	    // to-do: will need to setup proper response from the server side to get return status, work ID, etc. 
	    //alert("Data: " + data + "\nStatus: " + status);

	    console.log('work created by now...');

	  	var this_input = $('div[data-behavior="parent-relationships-institutions"]').find('input[name="biological_specimen[find_parent_work]"]');
			this_input.val('x346d4165');

			var this_element = $('[data-behavior="parent-relationships-institutions"]');

			var new_data = {
				id: "x346d4165", 
				text: "Duke 724"
			};
	    this_element.data('new-work-created', new_data);
			var this_add_btn = $(this_div).data("add-button");
			$(this_add_btn).trigger("click");
	  });
	  
//	  console.log(this.input.select2('data'))	
		$(this_div).hide();
   	$(this_div).html('');
		return false;
  });
  $(this_div).on("click", "button.cancel", function() {
		$(this_div).hide();
   	$(this_div).html('');
  });
}
