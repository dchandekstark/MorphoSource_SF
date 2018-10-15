// Javascript code for the Image Capture Event add/edit form

$(document).on('turbolinks:load', function() {
    //console.log('ready... length='+ $('form[id*="imaging_event"]').length) ;
    if ($('form[id*="imaging_event"]').length) { // in ICE add/edit form page
        showFieldsByModality();
    }
});

var showFieldsByModality = function() {
    // hide modality specific fields, then show only specific fields based on the modality
    $('.ie_xray_ct, .ie_photogrammetry, .ie_photography').addClass('hide').removeClass('show');
    var selectedModality = $('select[name="imaging_event[ie_modality]"]').val();
    //console.log('ICE: ' + selectedModality);
    switch(selectedModality) {
        case 'MicroNanoXRayComputedTomography':
            $('.ie_xray_ct').addClass('show').removeClass('hide');
            $('.ie_photogrammetry, .ie_photography').children('input, select').val('');
            break;
        case 'MedicalXRayComputedTomography':
            $('.ie_xray_ct').addClass('show').removeClass('hide');
            $('.ie_photogrammetry, .ie_photography').children('input, select').val('');
            break;
        case 'Photogrammetry':
            $('.ie_photogrammetry').addClass('show').removeClass('hide');
            $('.ie_xray_ct').children('input, select').val('');
            break;
        case 'Photography':
            $('.ie_photography').addClass('show').removeClass('hide');
            $('.ie_xray_ct').children('input, select').val('');
            $('.ie_photogrammetry').children('input#imaging_event_background_removal, select#imaging_event_focal_length_type').val('');
            break;
        default: // any other modality
            $('.ie_xray_ct, .ie_photogrammetry, .ie_photography').children('input, select').val('');
    }
}

