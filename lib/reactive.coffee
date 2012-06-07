Meteor.deps.add_reactive_variable = (object, name, value) ->
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
  
  # read the value of the variable _without_ setting up invalidation
  object["read_#{name}"] = -> variable
  
  variable

# listen to a reactive fn until it returns true
Meteor.deps.await = (fn, callback) ->
  done = false
  ctx = new Meteor.deps.Context()
  ctx.on_invalidate -> 
    Meteor.deps.await(fn, callback) unless done
  ctx.run ->
    if fn()
      done = true
      callback()
  