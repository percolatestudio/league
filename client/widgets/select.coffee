# this only get set first off, it's not reactive right now (TODO)
Template.select.selected_text = ->
  selected_option = _.find(this.options, (o) -> o.selected)
  selected_option.text if selected_option
Template.select.events = 
  'change select': (event) ->
    text = $(event.target).find('option:selected').text()
    $(event.target).closest('.select').find('.selected_text').text(text)
