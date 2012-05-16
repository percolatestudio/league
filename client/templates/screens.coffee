## The file in which we determine which screen to render..
Template.screens.visible_page = -> Session.get('visible_page') || 'home'