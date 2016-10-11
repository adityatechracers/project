class StoreFactory 
  @local: ->
    store 
  @session: ->
    store.session

cork.StoreFactory = StoreFactory 