Session.set 'facebook_friends', null
Session.set 'current_friend_filter', ''

grab_facebook_friends = ->
  return if self.searching # this can only be called once
  return unless AuthSystem.logged_in() # not ready to start searching yet
  
  self.searching = true
  FB.api '/me/friends', (response) ->
    # FIXME-- this could be paginated.. this is NOT all friends
    all_friends = _.map(response.data, (fd) -> Player.new_from_facebook(fd) )
    Session.set 'facebook_friends', all_friends
  
Template.players.team = -> current_team()
Template.players.games_path = -> games_path(this)
Template.players.cant_continue = -> not current_team().attributes.players_required

Template.players.players = -> 
  current_players()
Template.players.alone_in_team = -> current_players().length <= 1
Template.players.events =
  'click .remove_player': (event) ->
    current_team().remove_player(this)
  'change [name=players_required]': (event) ->
    current_team().update_attribute('players_required', $(event.target).val())

Template.player.is_self = -> current_user() and this.id == current_user().id

Template.player.facebook_profile_url = -> 
  this.facebook_profile_url()

Template.player.in_team_class = -> 
  'in_team' if current_team() and (current_team().players({facebook_id: this.attributes.facebook_id}).length > 0)
  
Template.add_player.results = -> 
  if Session.equals('facebook_friends', null)
    grab_facebook_friends()
    []
  else
    all_friends = Session.get('facebook_friends')
    match = (f) -> f.attributes.name.match(Session.get('current_friend_filter'))
      
    f for f in all_friends when match(f)

Template.add_player.events = 
  'keyup input[name*=name]': (event) -> 
    Session.set 'current_friend_filter', new RegExp $(event.target).val(), 'i'
  'click .player_list li': (event) ->
    team = current_team()
    
    team.add_player(this)

Template.players.players_required_data = -> 
  required = parseInt(current_team().attributes.players_required)
  {
    icon: 'player'
    name: 'players_required',
    options: ({text: "#{i} players", value: i, selected: i == required} for i in [3..18])
  }