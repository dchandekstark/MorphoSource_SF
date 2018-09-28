// Javascript view functions for show/edit forms

function show_fields(field_array) {
	$(field_array.join(',')).removeClass('hide');
}

function hide_fields(field_array, clear = true) {
	$(field_array.join(',')).addClass('hide');
	if (clear) {
		$(field_array.join(',')).children('input, select').val('');
	}
}

function adjust_form_physical_object_type() {
	if ($('#physical_object_physical_object_type').val() == 'BioSpec') {
		show_fields(['.physical_object_idigbio_recordset_id', '.physical_object_idigbio_uuid', '.physical_object_is_type_specimen', '.physical_object_occurrence_id', '.physical_object_sex']);
		hide_fields(['.physical_object_cho_type', '.physical_object_contributor', '.physical_object_creator', '.physical_object_material']);
	} else if ($('#physical_object_physical_object_type').val() == 'CHO') {
		show_fields(['.physical_object_cho_type', '.physical_object_contributor', '.physical_object_creator', '.physical_object_material']);
		hide_fields(['.physical_object_idigbio_recordset_id', '.physical_object_idigbio_uuid', '.physical_object_is_type_specimen', '.physical_object_occurrence_id', '.physical_object_sex']);
	} else {
		hide_fields(['.physical_object_cho_type', '.physical_object_contributor', '.physical_object_creator', '.physical_object_material', '.physical_object_idigbio_recordset_id', '.physical_object_idigbio_uuid', '.physical_object_is_type_specimen', '.physical_object_occurrence_id', '.physical_object_sex']);
	}
}

$(document).ready(function () {
	adjust_form_physical_object_type();
});

$(document).on('change', '#physical_object_physical_object_type', function() {
	adjust_form_physical_object_type();
});
