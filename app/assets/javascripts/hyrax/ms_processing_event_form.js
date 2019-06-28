$(document).on('turbolinks:load', function() {
  if ($('form[id*="processing_event"]').length) { // if PE form page
  	hide_fields(['.processing_event_processing_activity']);
    
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

    // remove the first set of fields if in editing (not adding) mode
    if (concatFieldCount > 0) {
      $(targetWrapperUl).children("li").remove();
    }

    // When editing a record, this populates the individual fields with previously saved metadata.
    for (i = 0; i < concatFieldCount; i++) {
      var concatFieldValue = concatFields[i].value;
      //console.log('concatFieldValue: '+concatFieldValue);

      var step = concatFieldValue.match(/^Step: ([0-9]+), Type: /)[1];
      var type = concatFieldValue.match(/, Type: (.*), Software: /)[1];
      var software = concatFieldValue.match(/, Software: (.*), Description: /)[1];
      var description = concatFieldValue.match(/, Description: (.*)/)[1];

      // Fill in values for first line
/*
      if (i == 0) {
        var typeSelectOject = $('select[name="processing_event[processing_activity_type][]"]')[0];
        for (var x = 0; x < typeSelectOject.length; x++){
          if (typeSelectOject.options[x].value == type)
            typeSelectOject.selectedIndex = x;
        }
        $('input[name="processing_event[processing_activity_software][]"]')[0].value = software;
        $('input[name="processing_event[processing_activity_description][]"]')[0].value = description;
      } else {
*/

        // Assemble new triple fields
        var li = document.createElement('li');
        li.className =  'field-wrapper input-group input-append';
        li.setAttribute('style', "display:flex; flex-direction:row; justify-content:space-evenly;");
        li.setAttribute('data-step', step);

        var stepInput = document.createElement('input');
        stepInput.className = "string multi_value optional form-control processing_event_processing_activity_step form-control multi-text-field";
        stepInput.setAttribute("id", "processing_event_processing_activity_step");
        stepInput.setAttribute("name", "processing_event[processing_activity_step][]");
        stepInput.setAttribute("style", "margin:5px; width:10%; border-radius:5px;");
        stepInput.value = step;
        li.appendChild(stepInput);

        appendProcessingActivityTypeSelect(li);
        /*
        $('<select />', {
          id : "processing_event_processing_activity_type_"+i,
          name : 'processing_event[processing_activity_type][]',
          class : "form-control select optional form-control",
          style : "margin:5px; width:33%; border-radius:5px;",
          append : [
            $('<option />', {value : "", text : ""}),
            $('<option />', {value : "type 1", text : "type 1"}),
            $('<option />', {value : "type 2", text : "type 2"}),
            $('<option />', {value : "type 3", text : "type 3"})
          ]
        }).appendTo(li);
        */
        // select the existing option
        $(li).find('select').val(type);


        var softwareInput = document.createElement('input');
        softwareInput.className = "string multi_value optional form-control processing_event_processing_activity_software form-control multi-text-field";
        softwareInput.setAttribute("id", "processing_event_processing_activity_software");
        softwareInput.setAttribute("name", "processing_event[processing_activity_software][]");
        softwareInput.setAttribute("style", "margin:5px; width:23%; border-radius:5px;");
        softwareInput.value = software;
        li.appendChild(softwareInput);

        var descriptionInput = document.createElement('input');
        descriptionInput.className = "string multi_value optional form-control processing_event_processing_activity_description form-control multi-text-field";
        descriptionInput.setAttribute("id", "processing_event_processing_activity_description");
        descriptionInput.setAttribute("name", "processing_event[processing_activity_description][]");
        descriptionInput.setAttribute("style", "margin:5px; width:33%; border-radius:5px;");
        descriptionInput.value = description;
        li.appendChild(descriptionInput);


        var span = document.createElement('span');
        span.className = "input-group-btn field-controls";
        span.innerHTML = `<button type="button" class="btn btn-link remove">
                            <span class="glyphicon glyphicon-remove"></span>
                            <span class="controls-remove-text">Remove</span>
                            <span class="sr-only"> previous
                              <span class="controls-field-name-text"> processing_event</span>
                            </span>
                          </button>`

        li.appendChild(span);
        targetWrapperUl.appendChild(li);

//      }
    }
    //console.log(targetWrapperUl);

    // sort the list items by 'step'
    $(targetWrapperUl).children("li").detach().sort(function(a, b) {
      //console.log($(a).data('step'));
      //return $(a).data('step').localeCompare($(b).data('step'));
      return +$(a).data('step') - +$(b).data('step');
    }).appendTo(targetWrapperUl);
    //console.log(targetWrapperUl);

    // Clear default rightsHolder fields when done.
    targetGroupUl.innerHTML = '';
    $(targetGroup).hide(); // hide the field label and add button

    // On submit, the three fields are concatenated and inserted into hidden default processing activity field.
    form.addEventListener("submit", function() {
      var processingActivityCount = $('select[name="processing_event[processing_activity_type][]"]').length;
      for (i = 0; i < processingActivityCount; i++) {

        var processingActivityStep = $('input[name="processing_event[processing_activity_step][]"]')[i].value || '';
        var processingActivityType = $('select[name="processing_event[processing_activity_type][]"]')[i].value || '';
        var processingActivitySoftware = $('input[name="processing_event[processing_activity_software][]"]')[i].value || '';
        var processingActivityDescription = $('input[name="processing_event[processing_activity_description][]"]')[i].value || '';

        // As long as at least one input is filled out, proceed with creating a processingActivity string. Otherwise, create an empty string.
        if ((processingActivityType != '') || (processingActivitySoftware != '')) {
          var processingActivity = "Step: " + processingActivityStep + ", Type: " + processingActivityType + ", Software: " + processingActivitySoftware + ", Description: " + processingActivityDescription;
        } else {
          var processingActivity = '';
        }
        buildTargetField(processingActivity, targetGroupUl);
        //alert('processingActivity: '+processingActivity);
        // clear the individual fields to avoid confusion
        $('select[name="processing_event[processing_activity_type][]"]')[i].value = '';
        $('input[name="processing_event[processing_activity_software][]"]')[i].value = '';
        $('input[name="processing_event[processing_activity_description][]"]')[i].value = '';
      }
    });

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

  } // end if PE form page
})

