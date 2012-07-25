DeployConfig.get 'facebookSecret', (secret) ->
  Meteor.accounts.facebook.setSecret(secret)
