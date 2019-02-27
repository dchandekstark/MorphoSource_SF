$(document).on('ready', function(){
  
  if ($('div[class="submission_flow"]').length) { // check if the page is submission flow page 
    cookie_expired_days = 90;
    // Begin Raw media flow
    $('#submission_choose_raw_or_derived_media_continue').click(function(event){
      event.preventDefault();
      var selected = $('input[name="submission[raw_or_derived_media]"]:checked').val();
      if (selected == 'Raw') {
        $('div#submission_choose_raw_or_derived_media').addClass('hide').removeClass('show');
        $('#submission_choose_biospec_or_cho').addClass('show').removeClass('hide');
        saveClick('#submission_raw_or_derived_media_raw,#submission_choose_raw_or_derived_media_continue', true);
      } else if (selected == 'Derived') {
        $('div#submission_choose_raw_or_derived_media').addClass('hide').removeClass('show');
        $('div#submission_parents_in_ms').addClass('show').removeClass('hide');
        saveClick('#submission_raw_or_derived_media_derived,#submission_choose_raw_or_derived_media_continue', true);
      }
    });
    
    $('#submission_choose_biospec_or_cho_continue').click(function(event){
      event.preventDefault();
      var selected = $('input[name="submission[biospec_or_cho]"]:checked').val();
      if (selected == 'biospec') {
        $('#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');
        $('div#submission_biospec').addClass('show').removeClass('hide');
        saveClick('#submission_biospec_or_cho_biospec,#submission_choose_biospec_or_cho_continue', false);
      } else if (selected == 'cho') {
        $('#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');
        $('div#submission_cho').addClass('show').removeClass('hide');
        saveClick('#submission_biospec_or_cho_cho,#submission_choose_biospec_or_cho_continue', false);
      }
    });
    

    /* remove later
    $('a#submission_show_create_biospec').click(function(event){
      event.preventDefault();
      $('div#submission_biospec_search').addClass('hide').removeClass('show');
      $('div#submission_choose_create_biospec').addClass('hide').removeClass('show');;
      $('div#submission_create_biospec').addClass('show').removeClass('hide');
    }); */

    $('a#submission_show_create_cho').click(function(event){
      event.preventDefault();
      $('div#submission_cho_search').addClass('hide').removeClass('show');
      $('div#submission_choose_create_cho').addClass('hide').removeClass('show');;
      $('div#submission_create_cho').addClass('show').removeClass('hide');
    }); 

    $('a#submission_show_create_institution').click(function(event){
      event.preventDefault();
      $('div#submission_institution_select').addClass('hide').removeClass('show');
      $('div#submission_choose_create_institution').addClass('hide').removeClass('show');;
      $('div#submission_create_institution').addClass('show').removeClass('hide');
    });
    
    // End Raw media flow
  
    // Begin Derived media flow 
    
    $('#btn_parents_not_in_morphosource').click(function(event){
      event.preventDefault();
      $('div#submission_parents_in_ms').addClass('hide').removeClass('show');
      $('div#submission_parents_not_in_ms').addClass('show').removeClass('hide');
      saveClick('#btn_parents_not_in_morphosource', false);
    });
    
    saveClick = function(id, fromStart) {
      var saved_step = '';
      if (!fromStart && getCookie('saved_step')) {
        var saved_step = getCookie('saved_step') + ',';
      }
      setCookie('saved_step', saved_step + id, cookie_expired_days);
    }

    $('#btn_parent_media_how_to_proceed_continue').click(function(event){
      event.preventDefault();
      $('div#submission_parents_not_in_ms').addClass('hide').removeClass('show');
      if ( $('input[name="submission[parent_media_how_to_proceed]"]:checked').val() == 'now' ) {
        // start over
        $('div#submission_choose_raw_or_derived_media').addClass('show').removeClass('hide');
        deleteCookie('saved_step');
        deleteCookie('last_render');
      } else {
        // go to phsyical object 
        $('#submission_choose_biospec_or_cho').addClass('show').removeClass('hide');
        saveClick('#submission_raw_or_derived_media_raw,#submission_choose_raw_or_derived_media_continue', true);
      }
      clearForms();
    });
    // End Derived media flow 
    
    $('#start_over').click(function(event){
      event.preventDefault();
      if (confirm('Click OK to start over, or CONFIRM to stay on the page')) {
        // set a cookie to clear all session variables when loading the initial page
        setCookie('ms_submission_start_over', 'yes', cookie_expired_days);
        location.href = "/submissions/new";
      }
    });

    var clearForms = function() {
      // if there are other forms (or radios) on the page that should not be cleared. Add condition here.
      $('form').each(function() {
        this.reset();
      });
      $('.radio_buttons').prop('checked', false);
    }
    
    $('#btn_add_parent').click(function(event){
      event.preventDefault();
      var currentParentList = $('input[id="submission_parent_media_list"]').val();
      var selectedId = $("input.parent_id").val();
      if (currentParentList.indexOf(selectedId) != -1) {
        // parent has already been added
        // todo: see if it is possible to exclude the already-added parents from the autocomplete dropdown
        alert('already added');
      } else {
        if (currentParentList != '')
          currentParentList += ',';
        currentParentList += selectedId;
        $('input[id="submission_parent_media_list"]').val(currentParentList);
        // display a new parent media row
        $('.parent_row:last-child').after(newParentRow(selectedId));
      }
      $('input[id="submission_parent_media_search"]').val('');
      $("input.parent_id").val('');
      $("input.parent_title").val('');
    });

    var newParentRow = function(id){
      var row = '<div class="parent_row ' + id + '">'
        + '<div class="col-sm-4"><div class="parent_title">'
        + $("input.parent_title").val() + '</div></div>' 
        + '<div class="col-sm-2"><a class="btn_remove_parent btn btn-primary" onClick="removeParent(\'' + id + '\')">Remove</a> <!--' + id + '--></div>'
        + '</div>';
      return row;
    }

    removeParent = function(id){
      event.preventDefault();
      $('div.' + id).remove();
      var currentParentList = $('input[id="submission_parent_media_list"]').val();
      var newParentList = removeValue(currentParentList, id);
      $('input[id="submission_parent_media_list"]').val(newParentList);
    }
    
    function removeValue(list, value) {
      list = list.split(',');
      list.splice(list.indexOf(value), 1);
      return list.join(',');
    }

    isRadioSelected = function(inputName) {
      // this function check and make sure a radio button is selected
      if ($('input[name="' + inputName + '"]:checked').val() === undefined) {
        // nothing selected
        return false;
      } else {
        return true;
      }
    }
    
    isDropdownSelected = function(selectName) {
      // this function check and make sure an option is selected in a dropdown
      if ($('select[name="' + selectName + '"]').prop('selectedIndex') == 0) {
        // nothing selected
        return false;
      } else {
        return true;
      }
    }
    
    gotoStep = function(pg, steps) {
      event.preventDefault();
      setCookie("last_render", pg, cookie_expired_days);
      saveClick(steps);
      location.reload();
    }
    /*
    saved_step = getCookie('saved_step');
    console.log('saved_step = '+ saved_step);
    if (saved_step == 'Raw') {
      $("input[id='submission_raw_or_derived_media_raw']").prop("checked", true).trigger("click");
      $('#submission_choose_raw_or_derived_media_continue').trigger("click");
    }
    */
    if (getCookie('saved_step')) {
      saved_step = getCookie('saved_step');
      last_render = getCookie('last_render');
      //console.log('saved_step = '+ saved_step);
      console.log('last_render = '+ last_render);
      switch(saved_step) {

        /*
        case 'Raw':
          $("input[id='submission_raw_or_derived_media_raw']").prop("checked", true).trigger("click");
          $('#submission_choose_raw_or_derived_media_continue').trigger("click");
          break;
        case 'Derived':
          $("input[id='submission_raw_or_derived_media_derived']").prop("checked", true).trigger("click");
          $('#submission_choose_raw_or_derived_media_continue').trigger("click");
          break;
        case 'biospec':
          $("input[id='submission_raw_or_derived_media_raw']").prop("checked", true).trigger("click");
          $('#submission_choose_raw_or_derived_media_continue').trigger("click");
          $("input[id='submission_biospec_or_cho_biospec']").prop("checked", true).trigger("click");
          $('#submission_choose_biospec_or_cho_continue').trigger("click");
          break;
        case 'cho':
          $("input[id='submission_raw_or_derived_media_raw']").prop("checked", true).trigger("click");
          $('#submission_choose_raw_or_derived_media_continue').trigger("click");
          $("input[id='submission_biospec_or_cho_cho']").prop("checked", true).trigger("click");
          $('#submission_choose_biospec_or_cho_continue').trigger("click");
          break;
        */
        default:
          var clickElements = saved_step.split();
          for (var i = 0; i < clickElements.length; i++) {
            console.log('clicking ' + clickElements[i]);
            $(clickElements[i]).trigger('click');
          }
      }
      
    }

  } // end if the page is submission flow page 
});

function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for(var i = 0; i <ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

function setCookie(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
  var expires = "expires="+d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function deleteCookie(cname) {
  var expires = "expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";  
  document.cookie = cname + "=;" + expires + ";path=/";
}
