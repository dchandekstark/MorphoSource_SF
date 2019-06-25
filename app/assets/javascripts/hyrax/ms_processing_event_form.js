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



// Puts concatenated values into processingActivityHolder on submit.
function buildTargetField(inputValue, targetGroupUl) {
  var li = document.createElement('li');

  var input = document.createElement('input');
  input.className = 'string multi_value optional processing_event_processing_activity form-control multi-text-field';
  input.setAttribute("id", "processing_event_processing_activity");
  input.setAttribute("name", "processing_event[processing_activity][]");
  input.value = inputValue;

  li.appendChild(input);
  targetGroupUl.appendChild(li);
}

$(document).on('turbolinks:load', function() {
  if ($('form[id*="processing_event"]').length) { // if media form page
  	//hide_fields(['.processing_event_processing_activity']);
    
    // concatenate rights holder name, type to rights holder
    var form = $('form[id*="processing_event"]')[0];

    // Check the processingActivity Field (will be hidden)
    var targetGroup = document.querySelector('div.processing_event_processing_activity');
    var targetGroupUl = targetGroup.querySelector("ul");
    var concatFields = targetGroup.querySelectorAll("input");
    var concatFieldCount = (targetGroup.querySelectorAll("input").length) - 1;

    // Two part processingActivity entry
    var targetWrapper = document.getElementById("processing_event_processing_activity_wrapper");
    var targetWrapperUl = targetWrapper.querySelector('ul');
    var targetWrapperLi = targetWrapper.querySelector('li');

    // When editing a record, this populates the rightsHolder fields with previously saved metadata.
    for (i = 0; i < concatFieldCount; i++) {
      var concatFieldValue = concatFields[i].value;
      //console.log('concatFieldValue: '+concatFieldValue);

      var type = concatFieldValue.match(/Type: (.*?), Software: /)[1];
      var software = concatFieldValue.match(/Software: (.*)/)[1];

      // Fill in values for first line
      if (i == 0) {
        var typeSelectOject = $('select[name="media[rights_holder_type][]"]')[0];
        for (var x = 0; x < typeSelectOject.length; x++){
          if (typeSelectOject.options[x].value == type)
            typeSelectOject.selectedIndex = x;
        }
        $('input[name="media[rights_holder_name][]"]')[0].value = name;
      } else {
        // Assemble new name, type 
        var li = document.createElement('li');
        li.className = 'field-wrapper input-group input-append';
        li.setAttribute('style', "display:flex; flex-direction:row; justify-content:space-evenly;");

        var nameInput = document.createElement('input');
        nameInput.className = "string multi_value optional form-control media_rights_holder_name form-control multi-text-field";
        nameInput.setAttribute("id", "media_rights_holder_name");
        nameInput.setAttribute("name", "media[rights_holder_name][]");
        nameInput.setAttribute("style", "margin:5px; width:50%; border-radius:5px;");
        nameInput.value = name;
        li.appendChild(nameInput);

        $('<select />', {
          id : "media_rights_holder_type_"+i,
          name : 'media[rights_holder_type][]',
          class : "form-control select optional form-control",
          style : "margin:5px; width:50%; border-radius:5px;",
          append : [
            $('<option />', {value : "", text : ""}),
            $('<option />', {value : "Copyright and License", text : "Copyright and License"}),
            $('<option />', {value : "Copyright", text : "Copyright"}),
            $('<option />', {value : "License", text : "License"})
          ]
        }).appendTo(li);
        // select the existing option
        $(li).find('select').val(type);

        var span = document.createElement('span');
        span.className = "input-group-btn field-controls";
        span.innerHTML = `<button type="button" class="btn btn-link remove">
                            <span class="glyphicon glyphicon-remove"></span>
                            <span class="controls-remove-text">Remove</span>
                            <span class="sr-only"> previous
                              <span class="controls-field-name-text"> RIGHTS HOLDER</span>
                            </span>
                          </button>`

        li.appendChild(span);

        targetWrapperUl.appendChild(li);

      }
    }

    // Clear default rightsHolder fields when done.
    targetGroupUl.innerHTML = '';
    $(targetGroup).hide(); // hide the field label and add button

    // On submit, the three fields are concatenated and inserted into hidden default processing activity field.
    form.addEventListener("submit", function() {
      var processingActivityCount = $('select[name="processing_event[processing_activity_type][]"]').length;
      for (i = 0; i < processingActivityCount; i++) {

        var processingActivityType = $('select[name="processing_event[processing_activity_type][]"]')[i].value || '';
        var processingActivitySoftware = $('input[name="processing_event[processing_activity_software][]"]')[i].value || '';
        var processingActivityDescription = $('input[name="processing_event[processing_activity_description][]"]')[i].value || '';

        // As long as at least one input is filled out, proceed with creating a processingActivity string. Otherwise, create an empty string.
        if ((processingActivityType != '') || (processingActivitySoftware != '')) {
          var processingActivity = "Type: " + processingActivityType + ", Software: " + processingActivitySoftware + ", Description: " + processingActivityDescription;
        } else {
          var processingActivity = '';
        }
        alert('processingActivity: '+processingActivity);
        buildTargetField(processingActivity, targetGroupUl);
      }
    });

  } // end if media form page
})

