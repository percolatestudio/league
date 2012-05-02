Session.set 'team_id', null

console.log(Session.get('team_id'))

# subscribe to the teams collection, and redirect to one as soon as it exists
Meteor.subscribe 'teams', ->
  return if Session.get('team_id')
  
  team = Teams.findOne({}, {sort: {name: 1}})
  Router.setTeam(team._id) if team
  
# always subscribe to the players and (TODO: upcoming) games for the given team
Meteor.autosubscribe ->
  return unless team_id = Session.get('team_id')
  
  Meteor.subscribe 'players', team_id
  Meteor.subscribe 'games', team_id

team = -> Teams.findOne(Session.get('team_id'))

Template.team.team_selected = -> team()?
Template.team.team_name = -> team().name
