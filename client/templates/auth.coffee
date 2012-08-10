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

Template.login_fields.signingUp = -> Session.get 'signing_up'
Template.login_fields.loginStatus = -> Session.get 'login_status'
Template.login_fields.events =
  'click .register': -> Session.set('signing_up', !Session.get('signing_up'))
  
  'submit [name=login_password]': (event) ->
    event.preventDefault()
    
    email = $(event.target).find('[name=email]').val()
    password = $(event.target).find('[name=password]').val()
    
    if Session.get 'signing_up'
      password_confirm = $(event.target).find('[name=password_confirm]').val()
      
      # the most basic of checks right now
      if password_confirm != password
        return Session.set('login_status', "ERROR: Passwords don't match!")
      
      Session.set('login_status', 'Signing up')
      Meteor.createUser {email: email, password: password}, (err, res) -> 
        Session.set('login_status', "ERROR: #{err.reason}") if err
        
    else
      Session.set('login_status', 'Logging in...')
      Meteor.loginWithPassword email, password, (err, res) ->
        Session.set('login_status', "ERROR: #{err.reason}") if err

Template.logged_in_user.facebook_profile_url = -> this.facebook_profile_url('square')
Template.logged_in_user.events =
  'click .logout': -> Meteor.logout()