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
  
  save: ->
    if @valid()
      if @id?
        @constructor._collection.update(@id, @attributes) 
      else
        console.log 'there'
        @id = @constructor._collection.insert(@attributes)
      
      true
    else
      false
  
  @create: (attrs)->
    record = new this(attrs)
    record.save()
    record