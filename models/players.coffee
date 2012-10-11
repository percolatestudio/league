# { name: "Tom Coleman", email: "tom@thesnail.org", facebook_id: 'xxx', team_ids: [..], 
#   authorized: true, messaged: true}

class Player extends Model
  constructor: (attrs) ->
    super(attrs)
    @attributes.team_ids ||= []
    
  valid: ->
    @errors = {}
    
    # Obviously we'd prefer rails style class-level validators
    # unless @attributes.name? and @attributes.name != ''
    #   @errors.name = 'must not be empty'
      
    # unless @attributes.facebook_id? and parseInt(@attributes.facebook_id) > 0
    #   @errors.facebook_id = 'must be a positive number'
    
    _.isEmpty(@errors)
  
  @find_by_userId: (userId) ->
    Players.findOne(Meteor.users.findOne(userId).player_id)
  
  @find_or_create_from_user: (user, extra) ->
    # FIXME -- what to do about old users?
    # if user.services.facebook
    #   player = Players.findOne(facebook_id: user.services.facebook.id)
    
    email = user.services.facebook?.email || user.emails[0].address
    
    return player if player = Players.findOne({email: email})
    
    # create a new player
    name = extra.profile?.name || email.split('@')[0]
    data = { name: name, email: email }
    data.facebook_id = user.services.facebook?.id
    
    this.create(data)
  
  display_name: ->
    @attributes.name || @attributes.email.split('@')[0]
  
  jersey_name: ->
    parts = display_name.split(' ')
    parts[parts.length - 1]
  
  profile_url: (type) ->
    type = 'normal' unless _.isString(type)
    
    if (@attributes.facebook_id)
      @facebook_profile_url(type)
    else
      Gravatar.imageUrl(@attributes.email, {default: 'retro'})
    
  facebook_profile_url: (type = 'normal') ->
    "https://graph.facebook.com/#{@attributes.facebook_id}/picture?type=#{type}"
    
  create_team: (attributes) ->
    team = new Team(attributes)
    team.add_player(this)
  
  send_facebook_message: (message, link, callback) ->
    data =
      method: 'send'
      to: @attributes.facebook_id
      message: message
      link: link
    FB.ui data, (result) =>
      # this is the only way we can tell if they've actually sent it, thanks FB
      if result?
        this.update_attribute('messaged', true)
        callback() if callback

Player.has_access = (userId, raw_player, fields) ->
  console.log('checking access for player')
  console.log(fields);
  console.log(raw_player);
  return true unless raw_player._id
  
  # obviously, you can edit yourself
  me = Player.find_by_userId(userId)
  return true if me.id == raw_player._id
  
  # otherwise check that the player is in a team with the user
  team_ids = Players.find(raw_player._id).attributes.team_ids
  our_team_ids = me.attributes.team_ids
  
  console.log(team_ids)
  console.log(our_team_ids)
  console.log(_.intersection(team_ids, our_team_ids));
  
  _.intersection(team_ids, our_team_ids) != []
  
Players = Player._collection = new Meteor.Collection 'players', {ctor: Player}

## add security
Players.allow
  insert: Player.has_access
  update: Player.has_access
  remove: Player.has_access
