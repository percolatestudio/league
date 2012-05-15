Template.auth.logged_in = -> logged_in()

Template.auth.events = 
  'click .login': -> ensure_login()
  'click .logout': -> logout()

