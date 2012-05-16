# this is a Facebook authentication system. With more thought it could be generalised
# and the FB system could be a subclass... thoughts for another day
class FBAuthSystem
  constructor: ->
    @login_callback = null
  
  init: ->
    # set up state change handler
    @_handleStateChange()
    
    # initialize our connection to FB.
    Facebook.load =>
      FB.init {appId: '227688344011052', channelUrl: Facebook.channelUrl, status: true}
      FB.Event.subscribe 'auth.statusChange', (response) =>
        if response.authResponse
          @_handleLogin(response.authResponse)
        else
          @_handleLogout()
  
  logged_in: -> not Session.equals('current_user', null)
  
  require_login: (callback = (->)) ->
    return callback() if @logged_in() # they are logged in

    # we haven't yet initialized facebook, so we need to just set the callback while we wait
    @login_callback = ->
      # at this point we are either logged in or not
      if @logged_in()
        callback()
      else
        # FIXME: what do we do if they deny access
        null

    # FIXME what if they've previously denied access?
   # they aren't logged in, so we'll ask facebook to try
    return FB.login null,  {scope: 'email'} if FB?
  
  logout: -> FB.logout() if @logged_in()
  
  _handleLogin: (authResponse) ->
    Meteor.call 'login', authResponse.userID, (error, user) -> 
      return Session.set('current_user', user) if user # the user already exists
      
      # better get some deets from the FB
      FB.api '/me', (me) -> 
        attributes = { name: me.name, facebook_id: me.id, email: me.email }
        Meteor.call 'create', attributes, (error, user) ->
          Session.set 'current_user', user
  
  _handleLogout: -> 
    Session.set 'current_user', null
  
  _handleStateChange: =>
    ctx = new Meteor.deps.Context()
    ctx.on_invalidate @_handleStateChange # reset
    ctx.run =>
      if not @logged_in()
        # this needs to be taken care of _after_ we check the session
        return if not FB? # haven't yet finished checking
        
        # we need to go back to the homepage
        window.Router.logout()
        
      else
        @login_callback() if @login_callback
        @login_callback = null
        
        # make sure we aren't on the homepage
        window.Router.login()
  
# prepare a singleton instance
AuthSystem = new FBAuthSystem
Meteor.startup -> AuthSystem.init()