class Model
  @_collection: null
  constructor: (attributes) ->
    @attributes = attributes
    @errors = {}
  
  valid: -> 
    true
  
  save: ->
    @constructor._collection.insert(@attributes) if @valid()
    _.isEmpty(@errors)
