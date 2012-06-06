Template.auth.logged_in = -> AuthSystem.logged_in()
Template.auth.from_season_ticket = ->
  document.location.hash.match /season-ticket/
Template.auth.team_name = ->
  /season-ticket="(.*)"/.exec(document.location.hash)[1]

Template.logged_in_user.current_user = -> current_user()
Template.logged_in_user.facebook_profile_url = -> this.facebook_profile_url('square')
Template.logged_in_user.events =
  'click .logout': -> AuthSystem.force_logout()