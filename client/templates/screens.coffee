## The file in which we determine which screen to render..
Template.screens.visible_page = -> Session.get('visible_page') || 'home'

Template.screens.events = 
  'click a[href]': (event) ->
    event.preventDefault()
    Router.navigate($(event.target).attr('href'), {trigger: true})