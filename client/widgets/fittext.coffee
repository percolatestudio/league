# FIXME -- this can be generalised a bit I think.
# 
# assumes the parent is a block level element, works by changing the font-size on the
# parent until the inner span is around the same width
jQuery.fn.fittext = ->
  # TODO, these should be configurable i suppose
  MAX_SIZE = 36
  MIN_SIZE = 8
  
  $element = $(this)
  $parent = $element.parent()
  font_size = parseInt($element.css('font-size'))
  parent_width = $parent.width()
  
  [min_tried, max_tried, last_tried] = [Math.min(font_size, MIN_SIZE), Math.max(font_size, MAX_SIZE), 0]
  iterations = 10
  # stop when we are no longer getting closer to the 'correct size'
  while font_size != last_tried and iterations > 0
    last_tried = font_size
    iterations -= 1
    
    # console.log "trying #{iterations}: #{font_size}"
    
    change = parent_width / $element.width()
    
    font_size *= change
    font_size = Math.floor(font_size)
    
    $parent.css('font-size', font_size)
    
    if font_size > last_tried
      # make sure we aren't jumping around; keep us in our 'valid' range
      font_size = Math.min(font_size, max_tried)
      
      # last tried was too small, so it's our new minimum
      min_tried = last_tried
    else
      font_size = Math.max(font_size, min_tried)
      max_tried = last_tried
  
  $parent.css 'font-size', font_size
  $element.css 'visibility', 'visible'
    
    