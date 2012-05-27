Template.home.events =
  'click .login': -> AuthSystem.require_login()
  'submit .create_team': (event) -> 
    $(event).preventDefault();
    $form = $(this)
    AuthSystem.require_login ->
      console.log $form