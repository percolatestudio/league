# { name: "Tom Coleman", email: "tom@thesnail.org", facebook_id: 'xxx', team_ids: [..], 
#   authorized: true, messaged: true}

class Player extends Model
  constructor: (attrs) ->
    super(attrs)
    @attributes.team_ids ||= []
    
  valid: ->
    @errors = {}
    
    # Obviously we'd prefer rails style class-level validators
    unless @attributes.name? and @attributes.name != ''
      @errors.name = 'must not be empty'
      
    # FIXME: email validator I guess
    # unless @attributes.email? and @attributes.email != ''
    #   @errors.email = 'must not be empty'
    
    unless @attributes.facebook_id? and parseInt(@attributes.facebook_id) > 0
      @errors.facebook_id = 'must be a positive number'
    
    _.isEmpty(@errors)
  
  @new_from_facebook: (facebook_data) ->
    facebook_data.facebook_id = facebook_data.id
    delete facebook_data.id
    new this(facebook_data)

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

Players = Player._collection = new Meteor.Collection 'players', {ctor: Player}
