Session.set 'facebook_friends', null
Session.set 'current_friend_filter', ''

grab_facebook_friends = ->
  return if self.searching # this can only be called once
  return unless current_player() # not ready to start searching yet
  
  self.searching = true
  # FIXME: what are we doing on this page now?
  # FB.api '/me/friends', (response) ->
  #   # FIXME-- this could be paginated.. this is NOT all friends
  #   all_friends = _.map(response.data, (fd) -> Player.new_from_facebook(fd) )
  #   Session.set 'facebook_friends', all_friends
  
Template.players.team = -> current_team()
Template.players.games_path = -> games_path(this)
Template.players.cant_continue = -> not current_team().attributes.players_required

Template.players.players = -> 
  current_players()
Template.players.alone_in_team = -> current_players().count() <= 1
Template.players.events =
  'click .start_season': (event) ->
    unless this.authorized()
      # a little hack so it happens after we browse to the new page (and so it's not auto closed)
      show_team_status(this)
      Session.set('opening_status_overlay', true)
  'click .remove_player': (event) ->
    current_team().remove_player(this)
  'change [name=players_required]': (event) ->
    current_team().update_attribute('players_required', $(event.target).val())

Template.player.is_self = -> current_player() and this.id == current_player().id

Template.player.facebook_profile_url = -> 
  this.facebook_profile_url()

Template.player.in_team_class = -> 
  'in_team' if current_team() and (current_team().players({facebook_id: this.attributes.facebook_id}).count() > 0)

# we need to reset the filter when we draw
Template.add_player.filter = -> Session.get('current_friend_filter').source
Template.add_player.results = -> 
  if Session.equals('facebook_friends', null)
    grab_facebook_friends()
    []
  else
    all_friends = Session.get('facebook_friends')
    match = (f) -> f.attributes.name.match(Session.get('current_friend_filter'))
      
    f for f in all_friends when match(f)

Template.add_player.events = 
  'submit [name=add_player]': (event) ->
    event.preventDefault()
    emails = $(event.target).find('[name=emails]').val().split(',')
    
    _.each emails, (email) => this.add_player_from_email(email)
      
  'keyup input[name*=name]': (event) -> 
    Session.set 'current_friend_filter', new RegExp $(event.target).val(), 'i'
  'click .player_list li': (event) ->
    # the server can look up whether we already have a player with this FB id
    Meteor.call 'add_player_to_team_from_facebook', current_team().id, this.attributes

Template.players.players_required_data = -> 
  required = parseInt(current_team().attributes.players_required)
  {
    include_blank: true
    icon: 'player'
    name: 'players_required',
    options: ({text: "#{i} players", value: i, selected: i == required} for i in [3..18])
  }