# FIXME
# for now ima use session variables for the state of the select.
# the alternative is to store them in the structure

Template.select.prepare_select = ->
  unless this._widget_id
    this._widget_id = "widgets.select.#{Meteor.uuid()}"
    Session.set "#{this._widget_id}.open", false
    Session.set "#{this._widget_id}.selected_value", this.value || this.options[0]
    
  this._widget_id

Template.select.selected_value = -> Session.get "#{this._widget_id}.selected_value"
Template.select.open = -> 'open' if Session.get "#{this._widget_id}.open"
Template.select.selected = -> 
  'selected' if Session.equals("#{this._widget_id}.selected_value", this.valueOf())
Template.select.events = 
  'click li:not(:first-child)': (e) ->
    # Grrrrr meteor... FIXME
    id = $(e.target).closest('.select').attr('id')
    Session.set("#{id}.selected_value", this.valueOf())
  'click': (e) ->
    # Grrrrr meteor... FIXME
    key = $(e.target).closest('.select').attr('id') + '.open'
    Session.set(key, !Session.get(key))
    