# this only get set first off, it's not reactive right now (TODO)
Template.select.selected_text = ->
  @_contexts ||= {}
  ctx = Meteor.deps.Context.current
  @_contexts[ctx.id] = ctx if ctx and not (ctx.id in @_contexts)
  
  unless @selected_text?
    selected_option = _.find(@options, (o) -> o.selected)
    @selected_text = selected_option.text if selected_option
  
  @selected_text
  
Template.select.events = 
  'change select': (event) ->
    @selected_text = $(event.target).find('option:selected').text()
    
    context.invalidate() for id, context of @_contexts
    @_contexts = {}
