class Logo
  @MAX_LINE_LENGTH = 20 # in chars

  @shapes = ['national', 'crown', 'shield', 'flatdiamond', 'darrow', 'uarrow', 'circle', 'flatcircle', 'bolt']
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
  @pick_font = -> @pick_X(WebFontConfig.logo_fonts)
  
  constructor: (@team, attributes = {}) ->
    @shape = attributes.shape || Logo.pick_shape()
    @colors = attributes.colors || Logo.pick_colors()
    @font = attributes.font || Logo.pick_font()
    
    @lines = attributes.lines || @calculate_lines()
  
  to_object: ->
    {shape: @shape, colors: @colors, font: @font, lines: @lines}
  
  render: (options = {}) ->
    @render_options = options
    @size = @render_options.size || 'large'
    return Template.logo(this)
  
  primary_color: -> @colors[0]
  secondary_color: -> @colors[1]
  
  player_deficit: -> @team.player_deficit()
  
  # calculate if the name should be split over 2 or more lines.
  #
  # we don't look at the actual size of the text here, just the number of chars
  #   as we can't reliably tell when the fonts have loaded anyway, so it's best 
  #   to be a bit conservative..
  calculate_lines: ->
    # first calcuate the word sizes
    words = @team.attributes.name.split /\s+/
    word_lengths = (word.length for word in words)
    
    ## ok, we are going to run a little brute force algorithm that optimizes:
    #     1. number of lines THEN
    #     2. minimum line length (this'll mean the lines are balanced) GIVEN
    #     3. all lines are less than MAX_LINE_LENGTH
    #
    # it'll take exponential time, could probably write a dynamic programming alg in poly, but who would bother
    
    # evaluate which configuration is better. returns true if lines_1 is better
    # configurations are lists of # of words, so we need to actually calculate lengths here
    better = (lines_1, lines_2) ->
      # it's inefficent to do this for each check, but who cares..
      lengths = (lines) -> 
        idx = 0 # where we are up to
        _.map lines, (word_count) ->
          length = word_count - 1 # the spaces
          length += l for l in word_lengths[idx...idx+word_count]
          idx += word_count
          length
          
      lengths_1 = lengths(lines_1)
      lengths_2 = lengths(lines_2)
      
      # 3.
      return false unless _.all(lengths_1, (l) -> l < Logo.MAX_LINE_LENGTH)
      return true unless _.all(lengths_2, (l) -> l < Logo.MAX_LINE_LENGTH)
      
      # 1.
      return true if lines_1.length < lines_2.length
      return false if lines_1.length > lines_2.length 
      
      # 2.
      _.min(lengths_1) >= _.min(lengths_2)
    
    # Ok, the algorithm is fairly straightforward
    find_best = (so_far, words_left, best) ->
      # we have a configuration, test it against best
      if words_left == 0
        return so_far unless best
        return if better(so_far, best) then so_far else best
        
      for count in [1 .. words_left]
        # find the best after appending count
        best = find_best(so_far.concat(count), words_left - count, best)
      best
    
    # find the best one, the last argument marks no best found yet
    configuration = find_best([], words.length, null)
    
    idx = 0 # where we are up to
    _.map configuration, (word_count) ->
      line = words[idx...idx+word_count].join(' ')
      idx += word_count
      line
  
  # calculate the 'correct' font size by rendering offscreen
  #
  # note that the way fonts work mean that multiplying font-size by 10 doesn't
  #   mean that the width will be exactly 10 times bigger. So we need to use
  #   an recursive 'cartesian method'
  font_size: ->
    @_font_sizes ||= {}
    
    if !@fonts_were_active and Session.get('fonts_active')
      @fonts_were_active = true
      @_font_sizes = {}
    
    return @_font_sizes[@size] if @_font_sizes[@size]
    # console.log "calculating font_size @ #{@size} for #{@team.attributes.name}"
    
    # these are the ranges that we've tried
    [min_tried, max_tried, last_tried] = [8, 36, 0]
    
    # set a starting font_size that's a maximum
    @_font_sizes[@size] = max_tried
  
    $hidden_div = $('<div>').css({visibility: 'hidden'})
    $('body').append($hidden_div.append(@render(@render_options)))
    logo_width = $hidden_div.find('#logo').width()
    
    iterations = 10
    # stop when we are no longer getting closer to the 'correct size'
    while @_font_sizes[@size] != last_tried and iterations > 0
      # console.log "trying #{iterations}: #{@_font_sizes[@size]}"
      # and loop
      last_tried = @_font_sizes[@size]
      iterations -= 1
      
      change = logo_width / $hidden_div.find('h3').get(0).scrollWidth
      
      # now scale by the right amount to make us fit; this is our next try
      @_font_sizes[@size] *= change
      @_font_sizes[@size] = Math.floor(@_font_sizes[@size])
      
      $hidden_div.find('h3').css('font-size', @_font_sizes[@size])
      
      if @_font_sizes[@size] > last_tried
        # make sure we aren't jumping around; keep us in our 'valid' range
        @_font_sizes[@size] = Math.min(@_font_sizes[@size], max_tried)
        
        # last tried was too small, so it's our new minimum
        min_tried = last_tried
      else
        @_font_sizes[@size] = Math.max(@_font_sizes[@size], min_tried)
        max_tried = last_tried
      
      
    $hidden_div.detach()
    @_font_sizes[@size]
    