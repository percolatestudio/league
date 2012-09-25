# I'm not sure if this is the best way to hook in here (as it also allows us to modify
#  the user, which we don't want to to do). But it gets the job done.
Meteor.accounts.onCreateUser (options, extra, user) ->
  
  # create a player that is attached to this user
  console.log "creating/updating player"
  
  player = Player.find_or_create_from_user(user, extra)
  
  _.extend(user, extra)
  user.player_id = player.id
  user

# publish the player_id field
Meteor.publish null, -> 
  if this.userId()
    Meteor.users.find(this.userId(), {fields: {player_id: true}})
  