class Modal 
  constructor: (modal) ->
    console.log('constructor', modal)
    @$modal = $(modal)
  load: (url) ->
    console.log('load!!!', url, @$modal, @$modal.load)
    @$modal.load url, =>
      @$modal.modal 'show'
cork.Modal = Modal  