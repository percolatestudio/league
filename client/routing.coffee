# We just set the team name in the URL, nothing to see here
SportGridRouter = Backbone.Router.extend
  routes: 
    '': 'home'
    'leagues': 'leagues'
    ':team_id': 'players'
    ':team_id/season': 'games'
    
  home: -> 
    console.log 'at home'
    Session.set 'visible_page', 'home'
  leagues: -> 
    console.log 'at leagues'
    AuthSystem.instance.require_login ->
      Session.set 'visible_page', 'leagues'
  players: (team_id) -> 
    AuthSystem.instance.require_login ->
      Session.set 'team_id', team_id
      Session.set 'visible_page', 'players'
  games: (team_id) -> 
    AuthSystem.instance.require_login ->
      Session.set 'team_id', team_id
      Session.set 'visible_page', 'games'
    
  logout: ->
    console.log 'routing logout'
    this.navigate '', {replace: true, trigger: true}

Router = new SportGridRouter

Meteor.startup -> Backbone.history.start({pushState: true})