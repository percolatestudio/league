# I'm not sure if this is the best way to hook in here (as it also allows us to modify
#  the user, which we don't want to to do). But it gets the job done.
Meteor.accounts.onCreateUser (options, extra, user) ->
  
  # create a player that is attached to this user
  console.log "creating/updating player from #{user}"
  
  player = false
  
  # FIXME -- what to do about old users?
  # if user.services.facebook
  #   player = Players.findOne(facebook_id: user.services.facebook.id)
  
  # try and find the player by email
  player = Players.findOne({email: user.emails[0]})
  
  player ||= Player.new_from_user(user, extra)
  player.save()
  
  user.player_id = player.id
  user
