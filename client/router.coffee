# We just set the team name in the URL, nothing to see here
SportGridRouter = Backbone.Router.extend
  initWithAuthSystem: (authSystem) ->
    @authSystem = authSystem
  
  routes: 
    '': 'home'
    'loading': 'loading'
    'leagues': 'leagues'
    ':team_id': 'players'
    ':team_id/season': 'games'
    
  home: ->
    @authSystem.if_logged_in(
      => 
        console.log 'going to leagues'
        @navigate 'leagues', {replace: true, trigger: true}
      ->
        console.log 'at home'
        Session.set 'visible_page', 'home')
    
  leagues: -> 
    console.log 'at leagues'
    @require_login ->
      console.log 'setting visible page to leagues'
      Session.set 'visible_page', 'teams'
  players: (team_id) -> 
    @require_login ->
      Session.set 'team_id', team_id
      Session.set 'visible_page', 'players'
  games: (team_id) -> 
    @require_login ->
      Session.set 'team_id', team_id
      Session.set 'visible_page', 'games'
      
      # FIXME: how can we guarantee that the team has loaded properly when we get here?
      current_team().update_attribute('started', true)
      
    
  # I'm pretty sure this _isn't_ the right spot for this logic
  loading: -> 
    console.log 'at loading'
    Session.set 'visible_page', 'loading'
  
  sign_in: -> 
    console.log 'at sign_in'
    Session.set 'visible_page', 'signin'
  # not_authorized: -> Session.set 'visible_page', 'not_authorized'
  
  # force a login window to open up, sending us to sign_in if not
  require_login: (callback) ->
    console.log 'requiring login'
    console.log @authSystem.login_status()
    @loading() if @authSystem.logging_in()
    @authSystem.require_login(callback, => @sign_in())
  
  if_logged_in: (login_callback, logout_callback) ->
    @loading() if @authSystem.logging_in()
    @authSystem.if_logged_in(login_callback, logout_callback)

Router = new SportGridRouter
Router.initWithAuthSystem(AuthSystem)

Meteor.startup -> 
  Backbone.history.start({pushState: true})
  
########## FIXME: this is temporary until https://github.com/meteor/meteor/issues/142 is resolved
  
visible_page_watcher = ->
  ctx = new Meteor.deps.Context()
  ctx.on_invalidate visible_page_watcher # reset
  ctx.run -> $('.container').removeClass().addClass("container #{Session.get 'visible_page'}")
Meteor.startup -> visible_page_watcher()