# We just set the team name in the URL, nothing to see here
SportGridRouter = Backbone.Router.extend
  routes: 
    '': 'home'
    'signin': 'signin'
    'not_authorized': 'not_authorized'
    'leagues': 'leagues'
    ':team_id': 'players'
    ':team_id/season': 'games'
    
  home: -> 
    console.log 'at home'
    Session.set 'visible_page', 'home'
  leagues: -> 
    console.log 'at leagues'
    @require_login ->
      console.log 'setting visible page to leagues'
      Session.set 'visible_page', 'leagues'
  players: (team_id) -> 
    @require_login ->
      Session.set 'team_id', team_id
      Session.set 'visible_page', 'players'
  games: (team_id) -> 
    @require_login ->
      Session.set 'team_id', team_id
      Session.set 'visible_page', 'games'
      
  signin: -> 
    console.log 'at sigin'
    Session.set 'visible_page', 'signin'
  not_authorized: -> Session.set 'visible_page', 'not_authorized'
    
  # I'm pretty sure this _isn't_ the right spot for this logic
  loading: -> 
    console.log 'at loading'
    Session.set 'visible_page', 'loading'
  
  require_login: (callback) ->
    console.log "Router.require_login, #{AuthSystem.login_status()}"
    if AuthSystem.login_status() == null
      @loading()
      # try and login, recursing when we are done
      AuthSystem.require_login => @require_login(callback)
    else if AuthSystem.login_status() == 'logged_out'
      console.log 'here'
      console.log this
      @navigate 'signin', {replace: true, trigger: true}
    else if AuthSystem.login_status() == 'not_authorized'
      @navigate 'not_authorized', {replace: true, trigger: true}
    else
      callback()
      
  login: ->
    console.log "routing login, #{Session.get 'visible_page'}"
    if Session.equals 'visible_page', 'home'
      console.log 'better go to leagues'
      @navigate 'leagues', {replace: true, trigger: true}

Router = new SportGridRouter

Meteor.startup -> Backbone.history.start({pushState: true})