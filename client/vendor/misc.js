$(function() { 
  /*
  Kerning.js counterpart
  This runs anytime a new element is added to a page
  */
/*   Kerning.live();  */
  $(".add_team.btn").live("click", function() {
    $(this).closest('li').toggleClass('current');
  });
});