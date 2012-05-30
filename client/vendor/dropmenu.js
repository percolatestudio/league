(function( $ ){
  $(".dropdown").live("click", function() {
    $(this).closest('.dropmenu').toggleClass('current');
  });
})(jQuery);