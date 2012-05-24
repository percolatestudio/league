class Logo
  @shapes = ['shield', 'flatdiamond', 'darrow', 'uarrow', 'circle', 'flatcircle', 'National', 'bolt']
  @colors_list = [['#2E66B2', '#FF5C2B'], ['black', 'red'], ['red', 'white']]
  
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