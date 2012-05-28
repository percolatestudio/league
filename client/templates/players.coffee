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
Template.players.team_logo = -> 
  (new Logo(this)).render()

Template.players.players = -> current_players()
Template.players.alone_in_team = -> current_players().length <= 1
Template.players.is_self = -> this.id == current_user().id
Template.players.events =
  'click .remove_player': (event) ->
    current_team().remove_player(this)

  'click .start_season': (event) ->
    event.preventDefault()
    
    # we need to make a FB request here.. 
    # FIXME -- filter players who are good already
    data = 
      method: 'send'
      to: _.map(current_players(), (p) -> p.attributes.facebook_id)
      message: "#{current_user().attributes.name} has invited you to their new league team: #{current_team().attributes.name}"
      link: 'http://google.com'
    console.log data
    FB.ui data, (status) ->
      console.log 'request made'
      console.log status

Template.player.facebook_profile_url = -> 
  this.facebook_profile_url()

Template.player.in_team_class = -> 
  (Players.find({facebook_id: this.attributes.facebook_id}).count() > 0) && 'in_team'
  
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
  'click .results li': (event) ->
    team = current_team()
    
    team.add_player(this)
    console.log "team failed to save: #{team.full_errors()}" unless team.save()
