// Javascript view functions for show/edit forms

function show_fields(field_array) {
	$(field_array.join(',')).removeClass('hide');
}

function hide_fields(field_array, clear = true) {
	$(field_array.join(',')).addClass('hide');
	if (clear) {
		console.log(field_array.join(','));
		$(field_array.join(',')).children('input, select').val('');
	}
}

function adjust_form_media_type() {
	if ($('#media_media_type').val() == 'CTImageStack') {
		show_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_unit']);
		hide_fields(['.media_scale_bar_target_type', '.media_scale_bar_distance', '.media_scale_bar_units', '.media_map_type']);
	} else if ($('#media_media_type').val() == 'PhotogrammetryImageStack') {
		show_fields(['.media_scale_bar_target_type', '.media_scale_bar_distance', '.media_scale_bar_units']);
		hide_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_unit', '.media_map_type']);
	} else if ($('#media_media_type').val() == 'Mesh') {
		show_fields(['.media_unit', '.media_map_type']);
		hide_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_scale_bar_target_type', '.media_scale_bar_distance']);
	} else {
		hide_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_scale_bar_target_type', '.media_scale_bar_distance', '.media_scale_bar_units', '.media_unit', '.media_map_type']);
	}
}

$(document).ready(function () {
	show_fields(['.media_title']);
	hide_fields(['.media_scale_bar','.media_number_of_images_in_set']);
	adjust_form_media_type();
});

$(document).on('change', '#media_media_type', function() {
	adjust_form_media_type();
});
