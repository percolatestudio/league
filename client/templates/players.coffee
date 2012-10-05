Session.set 'facebook_friends', null
Session.set 'current_friend_filter', ''

Template.players.helpers
  team: -> current_team()

Template.team_details.helpers
  players_required_data: -> 
    required = parseInt(current_team().attributes.players_required)
    return {
      include_blank: true
      icon: 'player'
      name: 'players_required',
      options: ({text: "#{i} players", value: i, selected: i == required} for i in [3..18])
    }

Template.team_details.events = 
  'change [name=players_required]': (event) ->
    current_team().update_attribute('players_required', $(event.target).val())

Template.roster.helpers
  players: -> current_players()
  alone_in_team: -> current_players().count() <= 1
Template.roster.events =
  'click .remove_player': (event) ->
    current_team().remove_player(this)

Template.continue.helpers
  games_path: -> games_path(this)
  team_done: -> 'done' if current_team().team_done()
  roster_done: -> 'done' if current_team().roster_done()
  cant_continue: -> current_team().done()

Template.continue.events =
  'click .start_season': (event) ->
    unless this.authorized()
      # a little hack so it happens after we browse to the new page (and so it's not auto closed)
      show_team_status(this)
      Session.set('opening_status_overlay', true)

Template.player.is_self = -> current_player() and this.id == current_player().id

Template.player.in_team_class = -> 
  'in_team' if current_team() and (current_team().players({facebook_id: this.attributes.facebook_id}).count() > 0)

Template.add_player.events = 
  'submit [name=add_player]': (event) ->
    event.preventDefault()
    
    # a fairly simple reliable email regexp
    regexp = /\S+@\S+\.\S+/g
    emails = $(event.target).find('[name=emails]').val().match(regexp)
    
    _.each emails, (email) => 
      # some minor cleaning up
      email = email.replace(/^\W+|\W+$/, '')
      this.add_player_from_email(email)
