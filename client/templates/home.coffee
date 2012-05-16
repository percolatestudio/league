Template.home.events =
  'submit .create_team': -> 
    $form = $(this)
    AuthSystem.require_login ->
      console.log $form