class InvalidModelException
  constructor: (@record) ->
    @errors = @record.errors
  
  toString: ->
    "Invalid model: #{@record}: #{@record.full_errors()}"

class Model
  @_collection: null
  constructor: (attributes) ->
    @attributes = attributes || {}
    
    @id = @attributes._id
    delete @attributes._id if @id
    
    @errors = {}
  
  _meteorRawData: -> 
    data = @attributes
    data._id = @id
    data
  
  valid: -> true
  
  persisted: -> @id? and @id != null
  
  full_errors: ->
    ("#{name} #{error}" for name, error of @errors).join(', ')
  
  save: (validate = true) ->
    throw new InvalidModelException(this) unless not validate or @valid()
    
    @before_save() if @before_save?
    
    if @_temporary_model_context
      @_temporary_model_context.invalidate
    else if @persisted()
      @constructor._collection.update(@id, {$set: @attributes}) 
    else
      @id = @constructor._collection.insert(@attributes)
    
    this
  
  update_attributes: (attrs = {}) ->
    changed = false
    for key, value of attrs
      old_value = @attributes[key]
      @attributes[key] = value 
      changed ||= old_value != value
    @save() if changed or not @persisted()
  
  update_attribute: (key, value) ->
    attrs = {}
    attrs[key] = value
    @update_attributes(attrs)
  
  destroy: ->
    @constructor._collection.remove(@id) if @persisted
  
  @create: (attrs)->
    record = new this(attrs)
    record.save()
    record
  
  # This model doesn't save to the db right, just alerts the context that it's in
  temporary: (set) -> 
    if (set)
      @_temporary_model_context = Meteor.deps.Context.current
    else
      @_temporary_model_context = null
    this
  