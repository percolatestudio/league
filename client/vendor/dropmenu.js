(function( $ ){
/*   Fixme, why isnt this working */
  $(".dropdown").live("click", function() {
    $(this).closest('.dropmenu').toggleClass('current');
  });
  
})(jQuery);