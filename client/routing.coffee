# We just set the team name in the URL, nothing to see here
SportGridRouter = Backbone.Router.extend
  routes: {'': 'home', ':team_id': 'team'}
  home: -> Session.set 'team_id', null
  team: (team_id) -> Session.set 'team_id', team_id
  login: (user) ->
    if user and user.team_id
      this.navigate(user.team_id, {replace: true, trigger: true})

Router = new SportGridRouter

Meteor.startup -> Backbone.history.start({pushState: true})