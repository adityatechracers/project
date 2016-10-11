class Filters
  constructor: (store)-> 
    @store = null 
    if store 
      @store = store 
    else 
      @store = cork.StoreFactory.session()
  key:  =>
    "filters:#{@target}"

  _preSelectFilters: => 
    unless _.isEmpty(@selected)
      @$el.find(':checkbox').each( (index, element) =>
        $target = $(element)
        id = $target.data('id')
        unless _.isUndefined id 
          unless _.isUndefined @selected[id]
            $target.prop('checked', true)
          else 
            $target.prop('checked', false)  
      ) 

  _clearUndefines: =>
    @selected = _.omit(@selected, (value) ->
      return _.isNull(value)
    )  
  _saveStore: => 
    @store(@key(), @selected)  

  _setSelected: =>
    @selected = {}
    _key = @key()
    if @store.has _key 
      @selected = @store.get _key
    else 
      $.each @$el.find(':checked'), (index, value) => 
        id = $(value).data('id')
        unless _.isUndefined(id)
          @selected[id] = true

    @_clearUndefines() unless _.isEmpty(@selected)  
        
  activate: (@target) =>
    @$el = $(@target)
    @_setSelected()
    @_preSelectFilters()
    @$el.on('change', ':checkbox', (event) =>
      $target = $(event.currentTarget)
      id = $target.data('id')
      unless _.isUndefined(id)
        if $target.is(":checked")
          @selected[id] = true
        else
          @selected[id] = null
        @_saveStore()  
    )

cork.Filters = Filters    
