Template.auth.logged_in = -> AuthSystem.logged_in()

Template.auth.events = 
  'click .login': -> 
    AuthSystem.instance.require_login -> Router.leagues()
  'click .logout': -> AuthSystem.instance.logout()

