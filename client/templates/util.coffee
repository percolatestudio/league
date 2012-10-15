Template.fittext.created = ->
  # make a key to look up sizes
  this.base_key = Meteor.uuid()

Template.fittext.rendered = ->
  this.data.key = "#{this.base_key}-#{this.data}"
  size = Session.get(this.data.key)
  # fittext + store the size in the session
  unless size
    Session.set(this.data.key, $(this.find('span')).fittext())

Template.fittext.size = -> Session.get(this.key) + 'px'
