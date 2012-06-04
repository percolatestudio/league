Object.add_reactive_variable = (object, name, value) ->
  # the variable hidden via closures
  variable = value
  contexts = {}
  
  object[name] = ->
    ctx = Meteor.deps.Context.current
    contexts[ctx.id] = ctx if ctx and not (ctx.id in contexts)
    variable
  
  object["set_#{name}"] = (value) -> 
    variable = value
    
    context.invalidate() for id, context of contexts
    contexts = {}
  
  variable