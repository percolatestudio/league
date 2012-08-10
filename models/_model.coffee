class InvalidModelException
  constructor: (@record) ->
    @errors = @record.errors
  
  toString: ->
    "Invalid model: #{@record}: #{@record.full_errors()}"

# Temporary models is a local collection of records that are 'behaving' like they are saved
# indexed by a unique 'name', reactive just like real models are
class TemporaryModelCollection
  constructor: ->
    @_contexts = {}
    @_models = {}

  save: (id, record) -> 
    @_models[id] = record
    context.invalidate() for id, context of @_contexts[id]
    @_contexts[id] = {}

  get: (id) -> 
    if @_models[id]
      ctx = Meteor.deps.Context.current
      @_contexts[id][ctx.id] = ctx if ctx
      @_models[id]
      
  clear: (id) -> @save(id, null)
TemporaryModelCollection.instance = new TemporaryModelCollection()

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
    
    if @_temporary_model_id
      TemporaryModelCollection.instance.save(@_temporary_model_id, this)
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
  
  # register this as a temporary model identified by id, 
  #   now: .save() will just trigger reactivity, not actually save the record
  temporary_model: (id) -> 
    TemporaryModelCollection.instance.clear(@_temporary_model_id) if @_temporary_model_id
    @_temporary_model_id = id
    @save()

  