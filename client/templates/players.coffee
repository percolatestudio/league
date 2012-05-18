Session.set 'add_player_results', []

Template.players.team = -> current_team()
Template.players.players = -> Players.find().map( (p) -> new Player(p))

Template.player.facebook_profile_url = -> 
  this.facebook_profile_url()
  
Template.add_player.results = -> Session.get 'add_player_results'

Template.add_player.events = 
  'keyup input[name*=name]': (event) ->
    self = this
    # @all_friends is set if we've had a response from FB
    if self.all_friends
      re = new RegExp $(event.target).val(), 'i'
      results = (f for f in self.all_friends when f.attributes.name.match(re))
      Session.set 'add_player_results', results
      
    else if not self.searching
      self.searching = true
      # we haven't even started searching et
      FB.api '/me/friends', (response) ->
        
        # store the data and try again
        self.all_friends = _.map(response.data, (fd) -> Player.new_from_facebook(fd) )
  
  'click .results li': (event) ->
    team = current_team()
    
    if this.save()
      team.add_player(this)
      console.log "team failed to save: #{team.full_errors()}" unless team.save()
    else
      console.log "player failed to save: #{this.full_errors()}"
