[url, facebookAppId] = if Meteor.env.is_development
  console.log 'is development'
  ['http://localhost:3000', '227688344011052']
else
  console.log 'is not development'
  ['http://beta.getleague.com', '246944062081485']

Meteor.accounts.facebook.config(facebookAppId, url)