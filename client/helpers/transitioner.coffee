# sits in front of the router and provides 'current_page' and 'next_page',
# whilst setting the correct classes on the body to allow the transition
class Transitioner
  @EVENTS = 'webkitTransitionEnd.transitioner oTransitionEnd.transitioner transitionEnd.transitioner msTransitionEnd.transitioner transitionend.transitioner'
  
  constructor: ->
    Meteor.deps.add_reactive_variable(this, 'current_page', 'loading')
    Meteor.deps.add_reactive_variable(this, 'next_page')
  
  init: (Router) ->
    @current_page.set(Router.current_page())
    Meteor.deps.await (=> Router.current_page() != this.current_page(true)), =>
      this._transition_to Router.current_page()
    
  _transition_classes:  ->
    "transitioning from_#{@current_page(true)} to_#{@next_page(true)}"
  
  # need to be careful not to do anything reactive in here or we can get into loops
  _transition_to: (new_page) ->
    console.log "transitioning to #{new_page}"
    
    # better kill the current transition
    @_transition_end() if @next_page(true)
    
    return if new_page == @current_page(true)
    
    # Load up the next page
    @next_page.set(new_page)
    
    # Start the transition (need to wait until meteor + the browser has rendered...)
    Meteor.defer =>
      # we want to wait until the TE event has fired for both containers
      $('body').addClass(@_transition_classes())
        .on Transitioner.EVENTS, (e) => 
          @_transition_end() if ($(e.target).is('body'))
  
  _transition_end: ->
    $('body').off('.transitioner')
    classes = @_transition_classes()
    console.log "transition end #{classes}"
    $('body').removeClass(classes)
    
    # if there isn't a next page to go to, we can't do the switch
    return unless @next_page(true)
    @current_page.set(@next_page(true))
    @next_page.set(null)
    

Transitioner.instance = new Transitioner()
Meteor.startup ->
  Transitioner.instance.init(Router)
