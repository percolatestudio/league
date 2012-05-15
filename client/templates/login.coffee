Template.login.events = 
  'click .login': -> 
    FB.login _.identity,  {scope: 'email'}
