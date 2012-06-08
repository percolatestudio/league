## The file in which we determine which screen to render..
Template.screens.current_page = -> Transitioner.instance.current_page()
Template.screens.next_page = -> Transitioner.instance.next_page()


Template.screens.events = 
  'click .login': -> AuthSystem.force_login()
  
  'click a[href]': (event) ->
    # not sure why I have to do this
    return if event.isImmediatePropagationStopped()
    event.preventDefault()
    
    url = $(event.target).closest('a').attr('href').replace(/#.*$/, '')
    if url != '' and url != document.location.href
      Router.navigate(url, {trigger: true})
  
  'keyup .team_builder [name=name]': (event) ->
    disabled = ($(event.target).val() == '')
    $(event.target).closest('form').find('[type=submit]').attr('disabled', disabled)
  
  'submit .team_builder': (event) -> 
    event.preventDefault()
    
    # prepare the data
    $form = $(event.target)
    t = {}
    t[pair.name] = pair.value for pair in $form.serializeArray()
    
    # wait until the current_user function returns something
    Meteor.deps.await current_user, ->
      team = current_user().create_team(t)
      console.log team.full_errors() unless team.valid()
      
      Router.navigate(players_path(team), {replace: true, trigger: true})
      
    AuthSystem.force_login() # now force a login to make that happen
