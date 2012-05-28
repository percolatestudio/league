Template.logo_tester.teams = ->
  new Team({name: name}) for name in ['Wun Tun Pandas', 'Coconuts', 'Rejects', 'Airport Saints MX', 'Monash Tornados', \
   'Netiquette', 'Qwerty', 'Dumplings', 'Black Pearls', 'Crash Test Dummies']

Template.logo.games_link = -> games_link this.team