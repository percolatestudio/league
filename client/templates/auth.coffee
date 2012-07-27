Template.auth.logged_in = -> Meteor.user() and not Meteor.user().loading
Template.auth.team_from_season_ticket = -> 
  data = Session.get('team_from_season_ticket')
  new Team(data) if data

Template.auth.prepare_team_from_season_ticket = ->
  if document.location.hash.match /season-ticket/
    if Session.equals('team_from_season_ticket', undefined)
      Session.set 'team_from_season_ticket', false
      Meteor.call 'team_from_season_ticket', Session.get('team_id'), (error, data) ->
        Session.set 'team_from_season_ticket', data

Template.logged_in_user.facebook_profile_url = -> this.facebook_profile_url('square')
Template.logged_in_user.events =
  'click .logout': -> Meteor.logout()