class Model
  @_collection: null
  constructor: (attributes) ->
    @attributes = attributes || {}
    
    @id = @attributes._id
    delete @attributes._id if @id
    
    @errors = {}
  
  valid: -> true
  
  persisted: -> @id? and @id != null
  
  full_errors: ->
    ("#{name} #{error}" for name, error of @errors).join(', ')
  
  save: (validate = true) ->
    if not validate or @valid()
      if @persisted()
        @constructor._collection.update(@id, @attributes) 
      else
        @id = @constructor._collection.insert(@attributes)
      
      true
    else
      false
  
  destroy: ->
    @constructor._collection.delete(@id) if @persisted
  
  @create: (attrs)->
    record = new this(attrs)
    record.save()
    record