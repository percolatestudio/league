Template.fittext.data = -> {text: this}

Template.fittext_internals.created = ->
  # make a key to look up sizes
  this.base_key = Meteor.uuid()

Template.fittext_internals.rendered = ->
  this.data.key = "#{this.base_key}-#{this.data.text}"
  size = Session.get(this.data.key)
  # fittext + store the size in the session
  unless size
    Meteor.defer =>
      Session.set(this.data.key, $(this.find('span')).fittext())

Template.fittext_internals.size = -> 
  Session.get(this.key) + 'px'