Template.logo_tester.teams = ->
  names = ['Wun Tun Pandas', 'Coconuts', 'Rejects', 'Airport Saints MX', 'Monash Tornados', \
   'Netiquette', 'Qwerty', 'Dumplings', 'Black Pearls', 'Crash Test Dummies']
  
  for name, i in names
    new Team({name: name}) 

Template.logo.games_path = -> games_path this.team