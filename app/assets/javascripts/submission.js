$(document).on('ready', function(){
  
  if ($('div[class="submission_flow"]').length) { // check if the page is submission new page 
  
    // Begin Raw media flow
    $('#submission_choose_raw_or_derived_media_continue').click(function(event){
      event.preventDefault();
      var selected = $('input[name="submission[raw_or_derived_media]"]:checked').val();
      if (selected == 'Raw') {
        $('div#submission_choose_raw_or_derived_media').addClass('hide').removeClass('show');
        $('#submission_choose_biospec_or_cho').addClass('show').removeClass('hide');
      } else if (selected == 'Derived') {
        $('div#submission_choose_raw_or_derived_media').addClass('hide').removeClass('show');
        $('div#submission_parents_in_ms').addClass('show').removeClass('hide');
      }
    });
    
    $('#submission_choose_biospec_or_cho_continue').click(function(event){
      event.preventDefault();
      var selected = $('input[name="submission[biospec_or_cho]"]:checked').val();
      if (selected == 'biospec') {
        $('#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');
        $('div#submission_biospec').addClass('show').removeClass('hide');
      } else if (selected == 'cho') {
        $('#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');
        $('div#submission_cho').addClass('show').removeClass('hide');
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
    
    validateSelectedCho = function() {
      if ($('input[name="submission[cho_id]"]:checked').val() === undefined) {
        // nothing selected
        return false;
      } else {
        return true;
      }
    }
    // End Raw media flow
  
    // Begin Derived media flow 
    
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
    
    $('#start_over').click(function(event){
      event.preventDefault();
      if (confirm('Click OK to start over, or CONFIRM to stay on the page')) {
        // set a cookie to clear all session variables when loading the initial page
        var cookieName = 'ms_submission_start_over';
        var cookieValue = 'yes';
        var now = new Date();
        var time = now.getTime();
        time += 60 * 60 * 1000 * 1; // 1 hr
        now.setTime(time);
        document.cookie = cookieName +"=" + cookieValue + ";expires=" + now.toUTCString()
                          + ";path=/";
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

  }
});
