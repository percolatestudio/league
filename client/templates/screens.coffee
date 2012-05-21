## The file in which we determine which screen to render..
Template.screens.visible_page = -> Session.get('visible_page') || 'home'

Template.screens.events = 
  'click a[href]': (event) ->
    event.preventDefault()
    Router.navigate($(event.target).attr('href'), {trigger: true})
    
  'submit .team_builder': (event) -> 
    event.preventDefault()
    
    # prepare the data
    $form = $(event.target)
    t = {}
    t[pair.name] = pair.value for pair in $form.serializeArray()
    
    Router.require_login -> 
      console.log 'ok, logged in, creating team...'
      t.player_ids = [Session.get('current_user')._id]
      console.log t
      team = Team.create(t)
      console.log team.errors unless team.valid()
      # FIXME -- display errors..
      
      Router.navigate('leagues', {trigger: true})
