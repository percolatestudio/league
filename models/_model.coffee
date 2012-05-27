class Model
  @_collection: null
  constructor: (attributes) ->
    @attributes = attributes || {}
    
    @id = @attributes._id
    delete @attributes._id if @id
    
    @errors = {}
  
  valid: -> true
  
  persisted: -> @id != null
  
  full_errors: ->
    ("#{name} #{error}" for name, error of @errors).join(', ')
  
  save: (validate = true) ->
    if not validate or @valid()
      if @id?
        @constructor._collection.update(@id, @attributes) 
      else
        @id = @constructor._collection.insert(@attributes)
      
      true
    else
      false
  
  @create: (attrs)->
    record = new this(attrs)
    record.save()
    record