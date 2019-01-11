$(document).on('turbolinks:load', function(){
  
  if ($('div[class="submission_flow"]').length) { // check if the page is submission new page 
  
    console.log('in submission_flow');
    //$("#submission_device_id").select2();
    //$("#submission_institution_id").select2();

    //$('div#submission_new div#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');;
    //$('div#submission_new div#submission_biospec').addClass('hide').removeClass('show');

    //$('.new_media, .derived_media').addClass('hide').removeClass('show');
    
    $('input#submission_raw_or_derived_media_raw').click(function(event){
      $('#submission_choose_biospec_or_cho').addClass('show').removeClass('hide');
    });

    $('input#submission_biospec_or_cho_biospec').click(function(event){
      $('div#submission_biospec').addClass('show').removeClass('hide');
    });

    $('input#submission_biospec_or_cho_cho').click(function(event){
      event.preventDefault();
      alert('Not yet implemented');
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
  
    // functions for Derived device 
    $('input#submission_raw_or_derived_media_derived').click(function(event){
      $('div#submission_immediate_parents').addClass('show').removeClass('hide');
    });
    
    $('#btn_immediate_parents_continue').click(function(event){
      event.preventDefault();
      $('#btn_immediate_parents_continue').addClass('hide').removeClass('show');
      $('div#submission_parent_details').addClass('show').removeClass('hide');
    });

    $('#btn_parent_details_continue').click(function(event){
      event.preventDefault();
    });

  }
});
