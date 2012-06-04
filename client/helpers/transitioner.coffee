# sits in front of the router and provides 'current_page' and 'next_page',
# whilst setting the correct classes on the body to allow the transition
class Transitioner
  @EVENTS = 'webkitTransitionEnd.transitioner oTransitionEnd.transitioner transitionEnd.transitioner msTransitionEnd.transitioner transitionend.transitioner'
  
  constructor: ->
    @_current_page = 'loading'
    @_contexts = {current: {}, next: {}}
  
  init: ->
    @_read_current_page(true)
  
  current_page: ->
    @_add_context('current')
    @_current_page
  
  next_page: ->
    @_add_context('next')
    @_next_page
  
  _read_current_page: (first = false) ->
    ctx = new Meteor.deps.Context()
    ctx.on_invalidate(=> @_read_current_page())
    
    ctx.run =>
      if first
        @_current_page = Router.current_page()
        @_invalidate_contexts('current')
      else
        @_transition_to(Router.current_page())
  
  _transition_to: (new_page) ->
    console.log "transitioning to #{new_page}"
    # TODO -- deal with transitioning during a transition
    return if new_page == @_current_page
    
    # Load up the next page
    @_next_page = new_page
    @_invalidate_contexts('next')
    
    # Start the transition (need to wait until meteor + the browser has rendered...)
    Meteor.defer =>
      # we want to wait until the TE event has fired for both containers
      halfway = false
      $('body').addClass('transitioning')
        .on Transitioner.EVENTS, (e) => 
          if ($(e.target).is('.current_page,.next_page'))
            if halfway
              $('body').off('.transitioner')
              @_transition_end()
            else
              halfway = true
  
  _transition_end: ->
    console.log "transition end #{@_current_page} -> #{@_next_page}"
    @_current_page = @_next_page
    @_next_page = null
    @_invalidate_contexts('current')
    @_invalidate_contexts('next')
    
    $('body').removeClass('transitioning')
  
  _add_context: (key) ->
    ctx = Meteor.deps.Context.current
    @_contexts[key][ctx.id] = ctx if ctx and not (ctx.id in @_contexts[key])
  
  _invalidate_contexts: (key) ->
    context.invalidate() for id, context of @_contexts[key]
    @_contexts[key] = {}

Transitioner.instance = new Transitioner()
Meteor.startup ->
  Transitioner.instance.init()
