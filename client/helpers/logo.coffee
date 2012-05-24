class Logo
  # National doesn't work for some reason
  @shapes = ['shield', 'flatdiamond', 'darrow', 'uarrow', 'circle', 'flatcircle', 'bolt']
  @colors_list = [
    ['#2E66B2', '#FF5C2B'],
    ['#C51230', '#241E20'],
    ['#01487E', '#D60D39'],
    ['#020001', '#DF4601'],
    ['#0E2B55', '#BD3039'],
    ['#0E3386', '#D12325'],
    ['#023465', '#EE113D'],
    ['#333333', '#00A5B1'],
    ['#012143', '#C4953B'],
    ['#042462', '#B50131'],
    ['#004685', '#F7742C'],
    ['#132448', '#CDCBCE'],
    ['#00483A', '#FFBE00'],
    ['#CA1F2C', '#226AA9'],
    ['#000000', '#FFB40B'],
    ['#003166', '#1C8B85'],
    ['#01317B', '#E00016'],
    ['#0067A6', '#A5A5A5'],
    ['#01244C', '#D21033'],
    ['#F26532', '#29588B'],
    ['#006AB5', '#F0F4F7'],
    ['#4393D1', '#FBB529'],
    ['#ED174C', '#006BB6'],
    ['#002E62', '#FFC225'],
    ['#4A2583', '#F5AF1B'],
    ['#00330A', '#C82A39'],
    ['#004874', '#BC9B6A']
  ]



  
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
    