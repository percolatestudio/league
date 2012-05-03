Session.set 'team_id', null

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

Template.team_grid.team = -> 
  return unless team_id = Session.get('team_id')
  Teams.findOne(team_id)
  