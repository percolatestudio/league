Meteor.startup ->
  Facebook.load ->
    FB.init {appId: '227688344011052', channelUrl: Facebook.channelUrl, status: true}
    FB.Event.subscribe 'auth.statusChange', (response) ->
      if response.authResponse
        Meteor.call 'login', response.authResponse.userID, (error, user) -> 
          if user
            Router.login user
            return
        
          # better get some deets from the FB
          FB.api '/me', (me) -> 
            attributes = { name: me.name, facebook_id: me.id, email: me.email }
            Meteor.call 'create', attributes, (error, user) ->
              Router.login user
      else
        Session.set 'current_user', null

########## login related helpers:

# either just call with no arguments to initiate login steps,
#   or call it with a callback to 'require' login before continuing
login = (callback = _.identity) ->
  FB.login callback,  {scope: 'email'}

Template.login.events = 
  'click .login': login
