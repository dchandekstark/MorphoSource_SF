// Javascript code for the Image Capture Event add/edit form

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


// Puts concatenated values into filter on submit.
function buildFilter(filter, filterGroupUl) {
  var li = document.createElement('li');

  var input = document.createElement('input');
  input.className = 'string multi_value optional imaging_event_filter form-control multi-text-field';
  input.setAttribute("id", "imaging_event_filter");
  input.setAttribute("name", "imaging_event[filter][]");
  input.value = filter;

  li.appendChild(input);
  filterGroupUl.appendChild(li);
}

$(document).on('turbolinks:load', function(){
  //console.log('ready... length='+ $('form[id*="imaging_event"]').length) ;
  if ($('form[id*="imaging_event"]').length) { // if ICE add/edit form page

    showFieldsByModality();

    // concatenate filter material, filter thickness to filter

    var form = $('form[id*="imaging_event"]')[0];

    // Hidden Default Filter Field
    var filterGroup = document.querySelector('div.imaging_event_filter');
    var filterGroupUl = filterGroup.querySelector("ul");
    var concatFilters = filterGroup.querySelectorAll("input");
    var concatFilterCount = (filterGroup.querySelectorAll("input").length) - 1;

    // Three part filter entry
    var filterWrapper = document.getElementById("imaging_event_filter_wrapper");
    var filterWrapperUl = filterWrapper.querySelector('ul');
    var filterWrapperLi = filterWrapper.querySelector('li');

    // When editing a record, this populates the filter fields with previously saved metadata.
    for (i = 0; i < concatFilterCount; i++) {
      var concatFilterValue = concatFilters[i].value;
      //console.log('concatFilterValue: '+concatFilterValue);

      var material = concatFilterValue.match(/Filter material: (.*?), Filter thickness: /)[1];
      var thickness = concatFilterValue.match(/Filter thickness: (.*)/)[1];

      // Fill in values for first line
      if (i == 0) {
        filterWrapperLi.querySelectorAll('input')[0].value = material;
        filterWrapperLi.querySelectorAll('input')[1].value = thickness;
      } else {
        // Assemble new material, thickness inputs
        var li = document.createElement('li');
        li.className = 'field-wrapper input-group input-append';
        li.setAttribute('style', "display:flex; flex-direction:row; justify-content:space-evenly;");

        var materialInput = document.createElement('input');
        materialInput.className = "string multi_value optional form-control imaging_event_filter_material form-control multi-text-field";
        materialInput.setAttribute("id", "imaging_event_filter_material");
        materialInput.setAttribute("name", "imaging_event[filter_material][]");
        materialInput.setAttribute("style", "margin:5px; width:50%; border-radius:5px;");
        materialInput.value = material;
        li.appendChild(materialInput);

        var thicknessInput = document.createElement('input');
        thicknessInput.className = "string multi_value optional form-control imaging_event_filter_thickness form-control multi-text-field";
        thicknessInput.setAttribute("id", "imaging_event_filter_thickness");
        thicknessInput.setAttribute("name", "imaging_event[filter_thickness][]");
        thicknessInput.setAttribute("style", "margin:5px; width:50%; border-radius:5px;");
        thicknessInput.value = thickness;
        li.appendChild(thicknessInput);


        var span = document.createElement('span');
        span.className = "input-group-btn field-controls";
        span.innerHTML = `<button type="button" class="btn btn-link remove">
                            <span class="glyphicon glyphicon-remove"></span>
                            <span class="controls-remove-text">Remove</span>
                            <span class="sr-only"> previous
                              <span class="controls-field-name-text"> FILTER</span>
                            </span>
                          </button>`

        li.appendChild(span);

        filterWrapperUl.appendChild(li);

      }
    }

    // Clear default filter fields when done.
    filterGroupUl.innerHTML = '';
    $(filterGroup).hide(); // hide the field label and add button

    // On submit, material and thickness fields are concatenated and inserted into hidden default filter field.
    form.addEventListener("submit", function() {

      // If X-ray modality is selected, submit filter fields. Otherwise, submit an empty filter.
      var selectedModality = $('select[name="imaging_event[ie_modality]"]').val();
      if (selectedModality === 'MicroNanoXRayComputedTomography' ||
            selectedModality === 'MedicalXRayComputedTomography' ) {

        var filterCount = document.getElementsByClassName("imaging_event_filter_material").length;
        for (i = 0; i < filterCount; i++) {

          var filterMaterial = document.getElementsByClassName("imaging_event_filter_material")[i].value || '';
          var filterThickness = document.getElementsByClassName("imaging_event_filter_thickness")[i].value || '';

          // As long as at least one input is filled out, proceed with creating a filter string. Otherwise, create an empty string, which will not result in a new filter triple.
          if ((filterMaterial != '') || (filterThickness != '')) {
            var filter = "Filter material: " + filterMaterial + ", Filter thickness: " + filterThickness;
          } else {
            var filter = ''
          }
          //console.log('filter: '+filter);
          buildFilter(filter, filterGroupUl);
        }
      }
      else {
        buildFilter('', filterGroupUl);
      }
    });
    
  } // end if ICE add/edit form page
});
