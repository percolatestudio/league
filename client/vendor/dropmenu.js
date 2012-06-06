(function( $ ){
  $(".dropdown").live("click", function(event) {
    $(this).stop().closest('.dropmenu').toggleClass('current');
    event.stopPropagation();
  });
  $('html').live("click", function() {
		$('.dropmenu').removeClass('current');
	});
})(jQuery);