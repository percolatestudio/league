# sits in front of the router and provides 'current_page' and 'next_page',
# whilst setting the correct classes on the body to allow the transition
class Transitioner
  @EVENTS = 'webkitTransitionEnd.transitioner oTransitionEnd.transitioner transitionEnd.transitioner msTransitionEnd.transitioner transitionend.transitioner'
  
  constructor: ->
    Meteor.deps.add_reactive_variable(this, 'current_page', 'loading')
    Meteor.deps.add_reactive_variable(this, 'next_page')
  
  init: ->
    @_grab_current_page(true)
  
  _grab_current_page: (first = false) ->
    ctx = new Meteor.deps.Context()
    ctx.on_invalidate(=> @_grab_current_page())
    
    ctx.run =>
      if first
        @set_current_page(Router.current_page())
      else
        @_transition_to(Router.current_page())
  
  _transition_classes:  ->
    "transitioning from_#{@read_current_page()} to_#{@read_next_page()}"
  
  _transition_to: (new_page) ->
    console.log "transitioning to #{new_page}"
    
    # better kill the current transition
    @_transition_end() if @read_next_page()
    
    return if new_page == @read_current_page()
    
    # Load up the next page
    @set_next_page(new_page)
    
    # Start the transition (need to wait until meteor + the browser has rendered...)
    Meteor.defer =>
      # we want to wait until the TE event has fired for both containers
      halfway = false
      $('body').addClass(@_transition_classes())
        .on Transitioner.EVENTS, (e) => 
          if ($(e.target).is('.current_page,.next_page'))
            if halfway
              @_transition_end()
            else
              halfway = true
  
  _transition_end: ->
    $('body').off('.transitioner')
    classes = @_transition_classes()
    console.log "transition end #{classes}"
    $('body').removeClass(classes)
    
    # if there isn't a next page to go to, we can't do the switch
    return unless @read_next_page()
    @set_current_page(@read_next_page())
    @set_next_page(null)
    

Transitioner.instance = new Transitioner()
Meteor.startup ->
  Transitioner.instance.init()
