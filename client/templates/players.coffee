Session.set 'facebook_friends', null
Session.set 'add_player_results', []

grab_facebook_friends = ->
  return if self.searching # this can only be called once
  return unless FB? # not ready to start searching yet
  
  self.searching = true
  FB.api '/me/friends', (response) ->
    all_friends = _.map(response.data, (fd) -> Player.new_from_facebook(fd) )
    Session.set 'facebook_friends', all_friends
    Session.set 'add_player_results', all_friends
  
Template.players.team = -> current_team()
Template.players.players = -> Players.find().map( (p) -> new Player(p))

Template.player.facebook_profile_url = -> 
  this.facebook_profile_url()
  
Template.add_player.results = -> 
  if Session.equals('facebook_friends', null)
    grab_facebook_friends()
    []
  else
    Session.get 'add_player_results'

Template.add_player.events = 
  'keyup input[name*=name]': (event) ->
    all_friends = Session.get('facebook_friends')
    if all_friends
      re = new RegExp $(event.target).val(), 'i'
      results = (f for f in all_friends when f.attributes.name.match(re))
      Session.set 'add_player_results', results
  
  'click .results li': (event) ->
    team = current_team()
    
    if this.save()
      team.add_player(this)
      console.log "team failed to save: #{team.full_errors()}" unless team.save()
    else
      console.log "player failed to save: #{this.full_errors()}"
