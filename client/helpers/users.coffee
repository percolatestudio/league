##### In the future this will be added to a model. For now, use like a 'c-style' object

user_new_from_facebook = (facebook_data) ->
  facebook_data.facebook_id = facebook_data.id
  delete facebook_data.id
  facebook_data

user_facebook_profile_url = (self, type = 'square') ->
  "https://graph.facebook.com/#{self.facebook_id}/picture?type=#{type}"