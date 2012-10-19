Template.fittext.rendered = ->
  # fittext + store the size in the session
  unless Session.get(this.data.key)
    Session.set(this.data.key, $(this.find('span')).fittext())

Template.fittext.size = ->
  if this.key
    Session.get(this.key) + 'px'
