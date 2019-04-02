$(document).on('ready', function(){  
  if ($('div[class*="showcase"]').length) { // check if the page is showcase page

    $(".collapse-block").on("hide.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("a."+thisId).html('<span class="glyphicon glyphicon-triangle-bottom"></span> Expand for additional fields <span class="glyphicon glyphicon-triangle-bottom"></span>');
    });
    $(".collapse-block").on("show.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("a."+thisId).html('<span class="glyphicon glyphicon-triangle-top"></span> Collapse fields <span class="glyphicon glyphicon-triangle-top"></span>');
    });

  } // end if the page is showcase page 
});
