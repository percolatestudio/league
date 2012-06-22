ReactiveRouter = Backbone.Router.extend
  initialize: ->
    Meteor.deps.add_reactive_variable(this, 'current_page', 'loading')
    Backbone.Router.prototype.initialize.call(this)
  
  # simply wrap a page generating function in a context so we can set current_page
  # every time that it changes, but we can ensure that we only call it once (in case of side-effects)
  #
  # TODO -- either generalize this pattern or get rid of ti
  goto: (page_f) ->
    # so there's no need to specify constant functions
    unless typeof(page_f) is 'function'
      copy = page_f
      page_f = (-> copy) 
    
    context = new Meteor.deps.Context
    context.on_invalidate => 
      @goto(page_f)
    context.run =>
      @current_page.set page_f()

FilteredRouter = ReactiveRouter.extend
  initialize: ->
    @_filters = []
    ReactiveRouter.prototype.initialize.call(this)
  
  # normal goto, but runs the output of page_f through the filters
  goto: (page_f) ->
    # so there's no need to specify constant functions
    unless typeof(page_f) is 'function'
      copy = page_f
      page_f = (-> copy) 
    ReactiveRouter.prototype.goto.call this, => @apply_filters(page_f())
  
  filter: (fn, options = {}) ->
    options.fn = fn
    @_filters.push(options)
  
  apply_filters: (page) ->
    _.reduce(@_filters, ((page, filter) => @apply_filter(page, filter)), page)
  
  apply_filter: (page, filter) ->
    apply = if filter.only
      _.include(filter, page)
    else if filter.except
      not _.include(filter.except, page)
    else
      true
    
    if apply then filter.fn(page) else page

LeagueRouter = FilteredRouter.extend
  initialize: ->
    FilteredRouter.prototype.initialize.call(this)
    @filter @require_login, {except: ['home', 'loading', 'logo_tester']}
    @filter @close_overlays
  
  require_login: (page, logged_out_page = 'signin', loading_page = 'loading') ->
    # we are logged in AND the data has loaded from the server
    if Session.equals('fbauthsystem.login_status', 'logged_in') and current_user()
      page
    else if Session.equals('fbauthsystem.login_status', 'logged_out') or \
         Session.equals('fbauthsystem.login_status', 'not_authorized')
      logged_out_page
    else
      loading_page
  
  close_overlays: (page) ->
    close_overlays()
    page

  routes: 
    '': 'home'
    'leagues': 'leagues'
    'logo_tester': 'logo_tester'
    ':team_id': 'players'
    ':team_id/season': 'games'
  
  logo_tester: -> @goto('logo_tester')
    
  home: -> 
    @goto => @require_login('teams', 'home', 'loading')
  
  leagues: -> @goto('teams')
  players: (team_id) ->
    Session.set 'team_id', team_id
    @goto('players')
  games: (team_id) -> 
    Session.set 'team_id', team_id
    @goto =>
      # if they are logged in but there's no team, we may need to join the team
      if current_user() and not current_team()
        if (document.location.hash == '#season-ticket') and not Session.get('team_id_invalid')
          Meteor.call 'join_team', current_user().id, team_id, (error, joined) ->
            # something's wrong with this team
            Session.set('team_id_invalid', true) unless joined
          
          # show loading in the meantime
          return 'loading'
        
      # otherwise, standard logic
      @require_login('games', 'signin', 'loading')

Router = new LeagueRouter

Meteor.startup ->
  Backbone.history.start({pushState: true})