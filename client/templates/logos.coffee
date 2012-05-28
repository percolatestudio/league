Template.logo_tester.draw_logo_tester = -> Session.equals('visible_page', 'logo_tester')
Template.logo_tester.teams = ->
  names = ['Wun Tun Pandas', 'Coconuts', 'Rejects', 'Airport Saints MX', 'Monash Tornados', \
   'Netiquette', 'Qwerty', 'Dumplings', 'Black Pearls', 'Crash Test Dummies']
  
  for name, i in names
    new Team({name: name, logo_shape: Logo.shapes[i]}) 

Template.logo.games_link = -> games_link this.team