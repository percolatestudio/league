# We just set the team name in the URL, nothing to see here

# uses 'current_user' session var to monitor if we are logged in
AuthenticatedRouter = Backbone.Router.extend
  initialize: ->
    @_login_rules ||= {}
    @_current_page = null
    @_auth_page ||= 'signin'
    @_contexts = []
    Backbone.Router.prototype.initialize.call(this)
  
  require_login: (rules, auth_page) ->
    @_login_rules = rules
    @_auth_page = auth_page
  
  logged_in: ->
    ctx = new Meteor.deps.Context()
    ctx.on_invalidate(=> @invalidate_current_page())
    ctx.run ->
      not Session.equals('current_user_id', undefined) and not Session.equals('current_user_id', null)
    
  set_current_page: (page) ->
    @_current_page = page
    @invalidate_current_page()
    
  invalidate_current_page: -> 
    context.invalidate() for context in @_contexts
    @_contexts = []
  
  # set up a reactive variable 'current_page' which obeys the login rules
  current_page: ->
    @_contexts.push Meteor.deps.Context.current
    @_current_page_given_login()
  
  # actually work it out, not worrying about all the deps stuff
  _current_page_given_login: ->
    page = @_current_page
    
    check = if @_login_rules.only 
      _.include(@_login_rules.only, page)
    else if @_login_rules.except
      not _.include(@_login_rules.except, page)
    else
      true
    
    if check
      console.log 'checking logged in'
      if @logged_in() then page else @_auth_page
    else
      console.log "don't need to check logged in on this page"
      page

LeagueRouter = AuthenticatedRouter.extend
  initialize: ->
    @require_login {except: ['home', 'loading']}, 'signin'
    AuthenticatedRouter.prototype.initialize.call(this)
  
  routes: 
    '': 'home'
    'leagues': 'leagues'
    'logo_tester': 'logo_tester'
    ':team_id': 'players'
    ':team_id/season': 'games'
  
  logo_tester: -> @set_current_page('logo_tester')
    
  home: -> @set_current_page('home')
    
    # @authSystem.if_logged_in(
    #   => 
    #     console.log 'going to leagues'
    #     @navigate 'leagues', {replace: true, trigger: true}
    #   ->
    #     console.log 'at home'
    #     Session.set 'visible_page', 'home')
  
  
  leagues: -> @set_current_page('teams')
  players: (team_id) ->
    Session.set 'team_id', team_id
    @set_current_page('players')
  games: (team_id) -> 
    Session.set 'team_id', team_id
    @set_current_page('games')
    
      # # FIXME: how can we guarantee that the team has loaded properly when we get here?
      # current_team().update_attribute('started', true)
    
  # force a login window to open up, sending us to sign_in if not
  # require_login: (callback) -> null
  #   console.log 'requiring login'
  #   console.log @authSystem.login_status()
  #   @loading() if @authSystem.logging_in()
  #   @authSystem.require_login(callback, => @sign_in())
  # 
  # if_logged_in: (login_callback, logout_callback) -> null
  #   @loading() if @authSystem.logging_in()
  #   @authSystem.if_logged_in(login_callback, logout_callback)

Router = new LeagueRouter

Meteor.startup ->
  Backbone.history.start({pushState: true})
  
########## FIXME: this is temporary until https://github.com/meteor/meteor/issues/142 is resolved
  
current_page_watcher = ->
  ctx = new Meteor.deps.Context()
  ctx.on_invalidate current_page_watcher # reset
  ctx.run -> $('.container').removeClass().addClass("container #{Router.current_page()}")
Meteor.startup -> current_page_watcher()