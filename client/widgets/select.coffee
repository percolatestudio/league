# FIXME
# for now ima use session variables for the state of the select.
#   need to work out a nicer way to do this. 

Session.set 'select.open', false
Template.select.selected_value = -> Session.get('select.selected_value')
Template.select.open = -> 'open' if Session.get('select.open')
Template.select.selected = -> 
  'selected' if Session.equals('select.selected_value', this.valueOf())
Template.select.events = 
  'click li:not(:first-child)': ->
    Session.set('select.selected_value', this.valueOf())
  'click': -> 
    Session.set('select.open', !Session.get('select.open'))