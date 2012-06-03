# unconfirmed, not_playing, playing
Handlebars.registerHelper 'availability_class', (status = 0) ->
  Game.playing_states[status].toLowerCase().replace(' ', '_')

Handlebars.registerHelper 'logo', (team, options) ->
  team.logo.render options.hash

# a per-field editing system
editing_field_name = (name, record) -> "editing-#{record.id}-#{name}}"
_current_edit_field = null
open_edit_field = (name, record) ->
  _current_edit_field = editing_field_name(name, record)
  Session.set(_current_edit_field, true)
close_edit_field = (name, record) ->
  Session.set(editing_field_name(name, record), false)
close_current_edit_field = ->
  Session.set(_current_edit_field, false)


Handlebars.registerHelper 'if_equals', (left, right, options) ->
  left = left.call(this) if typeof left == 'function'
  right = right.call(this) if typeof right == 'function'
  if left.toString() == right.toString()
    options.fn(this)
  else
    options.inverse(this)

Handlebars.registerHelper 'if_editing', (name, options) ->
  if Session.equals(editing_field_name(name, this), true)
    options.fn(this)
  else
    options.inverse(this)

Handlebars.registerHelper 'pluralize', (word, count) ->
  count = count.call(this) if typeof count == 'function'
  if count == 1
    "#{count} #{word}"
  else
    "#{count} #{word}s"