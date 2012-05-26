(function( $ ){
/*   Fixme, why isnt this working */
  $(".dropdown").click(function() {
    $(this).closest('.dropmenu').toggleClass('current');
  });
  
})(jQuery);