(function( $ ){
  $(".dropdown").live("click", function() {
    $(this).stop().closest('.dropmenu').toggleClass('current');
    event.stopPropagation();
  });
  $('html').live("click", function() {
		$('.dropmenu').removeClass('current');
	});
})(jQuery);