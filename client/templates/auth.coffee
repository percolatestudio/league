Template.auth.logged_in = -> AuthSystem.logged_in()

Template.auth.events = 
  'click .login': -> AuthSystem.require_login()
  'click .logout': -> Router.logout()

