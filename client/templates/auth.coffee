Template.signin.preserve [
  '.button_container',
  '.header_container .logging_in', '.header_container .signing_up',
  '.link_container .logging_in', '.link_container .signing_up'
]

Template.signin.logged_in = -> Meteor.user() and not Meteor.user().loading
Template.signin.team_from_season_ticket = -> 
  data = Session.get('team_from_season_ticket')
  new Team(data) if data

Template.signin.prepare_team_from_season_ticket = ->
  if document.location.hash.match /season-ticket/
    if Session.equals('team_from_season_ticket', undefined)
      Session.set 'team_from_season_ticket', false
      Meteor.call 'team_from_season_ticket', Session.get('team_id'), (error, data) ->
        Session.set 'team_from_season_ticket', data


# We don't have an model here, so we'll use the Session to store error state
Template.login_fields.created = -> Session.set('login_fields.errors', {})
Template.login_fields.signing_up = -> Session.get 'signing_up'
Template.login_fields.email_error = -> 
  Session.get('login_fields.errors').email
Template.login_fields.password_error = -> 
  Session.get('login_fields.errors').password
Template.login_fields.password_confirm_error = -> 
  Session.get('login_fields.errors').password_confirm

Template.login_fields.events =
  'click .goto_register, click .goto_login': -> 
     Session.set('signing_up', !Session.get('signing_up'))
  
  'click .login_facebook': ->
    Meteor.loginWithFacebook (err) ->
      console.log(err) if err
  
  'submit [name=login_password]': (event) ->
    event.preventDefault()
    
    errors = {}
    
    email = $(event.target).find('[name=email]').val()
    errors.email = 'is required' unless email
    
    password = $(event.target).find('[name=password]').val()
    errors.password = 'is required' unless password
    
    if Session.get 'signing_up'
      password_confirm = $(event.target).find('[name=password_confirm]').val()
      
      # the most basic of checks right now
      if password_confirm != password
        errors.confirm = "doesn't match"
      
      return Session.set('login_fields.errors', errors) unless _.isEmpty(errors)
      
      Accounts.createUser {email: email, password: password}, (err, res) -> 
        Session.set('login_fields.errors', {email: err.reason}) if err
        
    else
      return Session.set('login_fields.errors', errors) unless _.isEmpty(errors)
      
      Meteor.loginWithPassword email, password, (err, res) ->
        Session.set('login_fields.errors', {email: err.reason}) if err

Template.logged_in_user.profile_url = -> this.profile_url('square')
Template.logged_in_user.events =
  'click .logout': -> Meteor.logout()