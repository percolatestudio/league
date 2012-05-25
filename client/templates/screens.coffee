## The file in which we determine which screen to render..
Template.screens.visible_page = -> Session.get('visible_page') || 'home'

Template.screens.events = 
  'click a[href]': (event) ->
    event.preventDefault()
    Router.navigate($(event.target).closest('a').attr('href'), {trigger: true})
    
  'submit .team_builder': (event) -> 
    event.preventDefault()
    
    # prepare the data
    $form = $(event.target)
    t = {}
    t[pair.name] = pair.value for pair in $form.serializeArray()
    
    Router.require_login -> 
      console.log 'ok, logged in, creating team...'
      console.log current_user()
      team = current_user().create_team(t)
      console.log team.full_errors() unless team.valid()