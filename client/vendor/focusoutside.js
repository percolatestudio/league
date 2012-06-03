// add an event to this object 'focusoutside' which will fire when the focus
// it or a child blurs AND the object which is focused is not it or a child
(function($) {
  $.fn.add_focusoutside = function() {
    // ensure it has a tabindex
    return $(this).attr('tabindex', function(i, old_index) {
      return old_index ? old_index : -1;
    }).bind('focusout', function() {
      var $this = $(this);
      // setting any timeout at all ensures that the event queue completely
      // finishes before the code inside the timeout runs. 
      // it seems activeElement doesn't get set until then
      Meteor.defer(function() {
        if (! ($this.has(document.activeElement).length || $this.is(document.activeElement))) {
          $this.trigger('focusoutside');
        }
      });
    });
  };
}(jQuery));