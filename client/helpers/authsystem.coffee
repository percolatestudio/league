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
      console.log 'fb loaded'
      FB.init 
        appId: '227688344011052'
        channelUrl: Facebook.channelUrl
      
      # get initial status (have to do it this way)
      FB.getLoginStatus (response) =>
        if response.status == 'connected'
          @_handleLogin(response.authResponse)
        else if response.status == 'not_authorized'
          @_handleNotAuthorized()
        else
          @_handleLogout()
      
      FB.Event.subscribe 'auth.login', (response) =>
        console.log 'auth.login'
        @_handleLogin(response.authResponse)
      
      FB.Event.subscribe 'auth.logout', =>
        console.log 'auth.logout'
        @_handleLogout()
  
  login_status: -> Session.get('current_user')
  logged_in: -> not _.include([null, 'logged_out', 'not_authorized'], @login_status())
  
  require_login: (callback = (->)) ->
    console.log 'requiring login'
    return callback() if @logged_in() # they are logged in

    # we haven't yet initialized facebook, so we need to just set the callback while we wait
    @login_callback = callback
    
    console.log "hmm... #{FB?}"
    # FIXME what if they've previously denied access?
    # they aren't logged in, so we'll ask facebook to try
    return FB.login null,  {scope: 'email'} if FB?
  
  logout: -> 
    console.log 'trying to logout'
    FB.logout() if @logged_in()
  
  _handleLogin: (authResponse) ->
    Meteor.call 'login', authResponse.userID, (error, user) -> 
      console.log "woo, login #{user}"
      return Session.set('current_user', user) if user # the user already exists
      
      # better get some deets from the FB
      FB.api '/me', (me) -> 
        attributes = { name: me.name, facebook_id: me.id, email: me.email }
        Meteor.call 'create', attributes, (error, user) ->
          Session.set 'current_user', user
  
  _handleLogout: -> 
    console.log 'FB logged us out?'
    Session.set 'current_user', 'logged_out'
  
  _handleNotAuthorized: -> 
    Session.set 'current_user', 'not_authorized'
  
  _handleStateChange: =>
    ctx = new Meteor.deps.Context()
    ctx.on_invalidate @_handleStateChange # reset
    ctx.run =>
      # don't need to do anything with this, just query it
      Session.get 'current_user'
      
      # this needs to be taken care of _after_ we check the session
      return if not FB? # haven't yet finished checking
      
      @login_callback() if @login_callback
      @login_callback = null
      
      # make sure we aren't on the homepage
      window.Router.login() if @logged_in()
  
# prepare a singleton instance
AuthSystem = new FBAuthSystem
Meteor.startup -> AuthSystem.init()