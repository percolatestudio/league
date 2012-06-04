# We just set the team name in the URL, nothing to see here

# uses 'current_user' session var to monitor if we are logged in
AuthenticatedRouter = Backbone.Router.extend
  initialize: ->
    @_page_f = () ->
    @_login_rules ||= {}
    @_contexts = {}
    Backbone.Router.prototype.initialize.call(this)
  
  require_login: (rules, auth_page = 'signin', loading_page = 'loading') ->
    @_login_rules = rules
    @_auth_page = auth_page
    @_loading_page = loading_page
  
  page_if_logged_in: (logged_in_page, logged_out_page, loading_page) ->
    # we are logged in AND the data has loaded from the server
    if Session.equals('fbauthsystem.login_status', 'logged_in') and current_user()
      logged_in_page
    
    else if Session.equals('fbauthsystem.login_status', 'logged_out') or \
          Session.equals('fbauthsystem.login_status', 'not_authorized')
      logged_out_page
      
    else
      loading_page
  
  apply_rules: (page) ->
    check = if @_login_rules.only 
      _.include(@_login_rules.only, page)
    else if @_login_rules.except
      not _.include(@_login_rules.except, page)
    else
      true
    
    if check
      console.log "checking logged in"
      @page_if_logged_in(page, @_auth_page, @_loading_page)
    else
      console.log "don't need to check logged in on this page"
      page
    
  goto: (page_or_rule) ->
    if typeof page_or_rule == 'function'
      @_page_f = page_or_rule
    else
      @_page_f = -> @apply_rules(page_or_rule)
    @invalidate_current_page()
    
  invalidate_current_page: -> 
    context.invalidate() for id, context of @_contexts
    @_contexts = {}
  
  # set up a reactive variable 'current_page' which obeys the login rules
  current_page: ->
    ctx = Meteor.deps.Context.current
    @_contexts[ctx.id] = ctx if ctx and not (ctx.id in @_contexts)
    @_page_f()

LeagueRouter = AuthenticatedRouter.extend
  initialize: ->
    @require_login {except: ['home', 'loading', 'logo_tester']}
    AuthenticatedRouter.prototype.initialize.call(this)
  
  routes: 
    '': 'home'
    'leagues': 'leagues'
    'logo_tester': 'logo_tester'
    ':team_id': 'players'
    ':team_id/season': 'games'
  
  logo_tester: -> @goto('logo_tester')
    
  home: -> 
    @goto -> @page_if_logged_in('teams', 'home', 'loading')
    
    # @authSystem.if_logged_in(
    #   => 
    #     console.log 'going to leagues'
    #     @navigate 'leagues', {replace: true, trigger: true}
    #   ->
    #     console.log 'at home'
    #     Session.set 'visible_page', 'home')
  
  
  leagues: -> @goto('teams')
  players: (team_id) ->
    Session.set 'team_id', team_id
    @goto('players')
  games: (team_id) -> 
    Session.set 'team_id', team_id
    @goto('games')
    
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