# We just set the team name in the URL, nothing to see here
SportGridRouter = Backbone.Router.extend
  routes: {':team_id': 'main'}
  main: (team_id) -> Session.set 'team_id', team_id
  setTeam: (team_id) -> this.navigate(team_id, {replace: true, trigger: true})


Router = new SportGridRouter

Meteor.startup -> Backbone.history.start({pushState: true})