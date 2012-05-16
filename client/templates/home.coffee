Template.home.events =
  'submit .create_team': -> 
    $form = $(this)
    AuthSystem.instance.require_login ->
      console.log $form