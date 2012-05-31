# FIXME
# for now ima use session variables for the state of the select.
# the alternative is to store them in the structure

Template.select.prepare_select = ->
  unless this._widget_id
    this._widget_id = Meteor.uuid() 
    Session.set "widgets.select.#{this._widget_id}.open", false
    Session.set "widgets.select.#{this._widget_id}.selected_value", this.value || this.options[0]
    
  null

Template.select.selected_value = -> Session.get "widgets.select.#{this._widget_id}.selected_value"
Template.select.open = -> 'open' if Session.get "widgets.select.#{this._widget_id}.open"
Template.select.selected = -> 
  'selected' if Session.equals("widgets.select.#{this._widget_id}.selected_value", this.valueOf())
Template.select.events = 
  'click li:not(:first-child)': ->
    Session.set("widgets.select.#{this._widget_id}.selected_value", this.valueOf())
  'click': ->
    key = "widgets.select.#{this._widget_id}.open"
    Session.set(key, !Session.get(key))
    