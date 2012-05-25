Session.set 'facebook_friends', null
Session.set 'current_friend_filter', ''

grab_facebook_friends = ->
  return if self.searching # this can only be called once
  return unless AuthSystem.logged_in() # not ready to start searching yet
  
  self.searching = true
  FB.api '/me/friends', (response) ->
    all_friends = _.map(response.data, (fd) -> Player.new_from_facebook(fd) )
    Session.set 'facebook_friends', all_friends
  
Template.players.team = -> current_team()
Template.players.players = -> current_players()

Template.players.events =
  'click .start_season': (event) ->
    event.preventDefault()
    
    # we need to make a FB request here.. 
    # FIXME -- filter players who are good already
    ids = _.map(current_players(), (p) -> p.attributes.facebook_id)
    message = "#{current_user().attributes.name} has invited you to their new league team: #{current_team().attributes.name}"
    FB.ui {to: ids, method: 'apprequests', message: message}, (status) ->
      console.log 'request made'
      console.log status

Template.player.facebook_profile_url = -> 
  this.facebook_profile_url()
  
Template.add_player.results = -> 
  if Session.equals('facebook_friends', null)
    grab_facebook_friends()
    []
  else
    all_friends = Session.get('facebook_friends')
    match = (f) -> 
      f.attributes.name.match(Session.get('current_friend_filter')) and \
        Players.find({facebook_id: f.attributes.facebook_id}).count() == 0
      
    f for f in all_friends when match(f)

Template.add_player.events = 
  'keyup input[name*=name]': (event) -> 
    Session.set 'current_friend_filter', new RegExp $(event.target).val(), 'i'
  'click .results li': (event) ->
    team = current_team()
    
    team.add_player(this)
    console.log "team failed to save: #{team.full_errors()}" unless team.save()
