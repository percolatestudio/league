class Logo
  # National doesn't work for some reason
  @shapes = ['shield', 'flatdiamond', 'darrow', 'uarrow', 'circle', 'flatcircle', 'bolt']
  @colors_list = [['#2E66B2', '#FF5C2B'], ['black', 'red'], ['red', 'white'], ['black', 'silver'], ['navy', 'white']]
  
  @pick_X = (list) -> list[parseInt(Math.random() * list.length)]
  
  @pick_shape = -> @pick_X(@shapes)
  @pick_colors = -> @pick_X(@colors_list)
  @pick_font = -> @pick_X(WebFontConfig.fonts)
  
  constructor: (@name, @shape, @colors, @font) ->
    # TODO -- pick a shape that can fit text
    @shape = Logo.pick_shape() unless @shape
    @colors = Logo.pick_colors() unless @colors
    @font = Logo.pick_font() unless @font
  
  render: ->
    return Template.logo(this)
  
  primary_color: -> @colors[0]
  secondary_color: -> @colors[1]
  
  # calculate the 'correct' font size by rendering offscreen
  # note that the way fonts work mean that multiplying font-size by 10 doesn't
  #   mean that the width will be exactly 10 times bigger. So we need to use
  #   an recursive 'cartesian method'
  font_size: ->
    return @_font_size if @_font_size
    
    # these are the ranges that we've tried
    [min_tried, max_tried, last_tried] = [8, 36, 0]
    
    # set a starting font_size that's a maximum
    @_font_size = max_tried
  
    # FIXME -- 200px is hard-coded here for now
    logo_width = 200
    $hidden_div = $('<div>').css({width: "#{logo_width}px", visibility: 'hidden'})
    $('body').append($hidden_div.append(@render()))
    
    iterations = 10
    # stop when we are no longer getting closer to the 'correct size'
    while @_font_size != last_tried and iterations > 0
      console.log "trying #{iterations}: #{@_font_size}"
      # and loop
      last_tried = @_font_size
      iterations -= 1
      
      change = logo_width / $hidden_div.find('h3').get(0).scrollWidth
      
      # now scale by the right amount to make us fit; this is our next try
      @_font_size *= change
      @_font_size = Math.floor(@_font_size)
      
      $hidden_div.find('h3').css('font-size', @_font_size)
      
      if @_font_size > last_tried
        # make sure we aren't jumping around; keep us in our 'valid' range
        @_font_size = Math.min(@_font_size, max_tried)
        
        # last tried was too small, so it's our new minimum
        min_tried = last_tried
      else
        @_font_size = Math.max(@_font_size, min_tried)
        max_tried = last_tried
      
      
    $hidden_div.detach()
    @_font_size
    