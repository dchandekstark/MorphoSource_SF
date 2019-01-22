$(document).on('turbolinks:load', function(){
  
  if ($('div[class="submission_flow"]').length) { // check if the page is submission new page 
  
    // possibly not needed. remove later
    //$("#submission_device_id").select2();
    //$("#submission_institution_id").select2();
    //$('div#submission_new div#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');;
    //$('div#submission_new div#submission_biospec').addClass('hide').removeClass('show');

    //$('.new_media, .derived_media').addClass('hide').removeClass('show');
    
    // Begin Raw media flow
    $('input#submission_raw_or_derived_media_raw').click(function(event){
      $('div#submission_choose_raw_or_derived_media').addClass('hide').removeClass('show');
      $('#submission_choose_biospec_or_cho').addClass('show').removeClass('hide');
    });

    $('input#submission_biospec_or_cho_biospec').click(function(event){
      $('#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');
      $('div#submission_biospec').addClass('show').removeClass('hide');
    });

    $('a#submission_show_create_biospec').click(function(event){
      event.preventDefault();
      $('div#submission_biospec_search').addClass('hide').removeClass('show');
      $('div#submission_choose_create_biospec').addClass('hide').removeClass('show');;
      $('div#submission_create_biospec').addClass('show').removeClass('hide');
    });

    $('a#submission_show_create_institution').click(function(event){
      event.preventDefault();
      $('div#submission_institution_select').addClass('hide').removeClass('show');
      $('div#submission_choose_create_institution').addClass('hide').removeClass('show');;
      $('div#submission_create_institution').addClass('show').removeClass('hide');
    });

    $('a#submission_show_create_device').click(function(event){
      event.preventDefault();
      $('div#submission_device_select').addClass('hide').removeClass('show');
      // the following line might not be needed.  remove it later
      //$('div#submission_choose_create_institution').addClass('hide').removeClass('show');;
      $('div#submission_create_device').addClass('show').removeClass('hide');
    });

    $('input#submission_biospec_or_cho_cho').click(function(event){
      //$('#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');
      alert('Not yet implemented');
    });

    // End Raw media flow
  
    // Begin Derived media flow 
    $('input#submission_raw_or_derived_media_derived').click(function(event){
      $('div#submission_choose_raw_or_derived_media').addClass('hide').removeClass('show');
      $('div#submission_parents_in_ms').addClass('show').removeClass('hide');
    });
    
    $('#btn_parents_not_in_morphosource').click(function(event){
      event.preventDefault();
      $('div#submission_parents_in_ms').addClass('hide').removeClass('show');
      $('div#submission_parents_not_in_ms').addClass('show').removeClass('hide');
    });
    
    $('#btn_parent_media_how_to_proceed_continue').click(function(event){
      event.preventDefault();
      $('div#submission_parents_not_in_ms').addClass('hide').removeClass('show');
      if ( $('input[name="submission[parent_media_how_to_proceed]"]:checked').val() == 'now' ) {
        // start over
        $('div#submission_choose_raw_or_derived_media').addClass('show').removeClass('hide');
      } else {
        // go to phsyical object 
        $('#submission_choose_biospec_or_cho').addClass('show').removeClass('hide');
      }
      clearForms();
    });
    // End Derived media flow 
    
    var clearForms = function() {
      // todo: if there are other forms (or radios) on the page that should not be cleared. Add condition here.
      $('form').each(function() {
        this.reset();
      });
      $('.radio_buttons').prop('checked', false);
    }
    
    /*
    $('#btn_parent_details_continue').click(function(event){
      event.preventDefault();
    });
    
    $('#submission_parent_media_type_parent_media_is_in_morphosource').click(function(event){
      
      $('#submission_media_select').addClass('show').removeClass('hide');
    }); 
    
    if ($('#parent_media_how_to_proceed').text() == 'PARENT_MEDIA_UPLOAD_FILE_LATER') {
      $("input#submission_raw_or_derived_media_raw").trigger("click");
      $('#submission_choose_biospec_or_cho').addClass('show').removeClass('hide');
    } 
    */

  }
});
