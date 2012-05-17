Session.set 'add_player_results', []

Template.players.team = -> Teams.findOne(Session.get('team_id'))
  
Template.add_player.results = -> Session.get 'add_player_results'

Template.add_player.events = 
  'keyup input[name*=name]': (event) ->
    self = this
    # @all_friends is set if we've had a response from FB
    if self.all_friends
      re = new RegExp $(event.target).val(), 'i'
      results = (f for f in self.all_friends when f.name.match(re))
      Session.set 'add_player_results', results
      
    else if not self.searching
      self.searching = true
      # we haven't even started searching et
      FB.api '/me/friends', (response) ->
        
        # store the data and try again
        self.all_friends = _.map(response.data, user_new_from_facebook)
        $(event.target).keyup()

Template.add_player_result.facebook_profile_url = -> user_facebook_profile_url(this)