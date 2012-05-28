Template.logo_tester.teams = ->
  names = ['Wun Tun Pandas', 'Coconuts', 'Rejects', 'Airport Saints MX', 'Monash Tornados', \
   'Netiquette', 'Qwerty', 'Dumplings', 'Black Pearls', 'Crash Test Dummies']
  
  for name, i in names
    new Team({name: name, logo_shape: Logo.shapes[i]}) 

Template.logo.games_link = -> games_link this.team