Meteor.startup ->
  Facebook.load ->
    FB.init {appId: '227688344011052', channelUrl: Facebook.channelUrl, status: true}
    FB.Event.subscribe 'auth.statusChange', (response) ->
      if response.authResponse
        on_login(response.authResponse)
      else
        on_logout()

on_login = (authResponse) ->
  Meteor.call 'login', authResponse.userID, (error, user) -> 
    return Router.login user if user # the user already exists
    
    # better get some deets from the FB
    FB.api '/me', (me) -> 
      attributes = { name: me.name, facebook_id: me.id, email: me.email }
      Meteor.call 'create', attributes, (error, user) ->
        Router.login user

on_logout = -> Session.set 'current_user', null

logged_in = -> not Session.equals('current_user', null)
  
########## login related helpers:

# either just call with no arguments to initiate login steps,
#   or call it with a callback to 'require' login before continuing
ensure_login = (callback = _.identity) ->
  if logged_in()
    callback()
  else
    FB.login callback,  {scope: 'email'}

logout = -> FB.logout() if logged_in
  