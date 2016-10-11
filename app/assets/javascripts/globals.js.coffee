class Globals
  @inputMask:
    money: ($scope) ->
      $element = $scope.find('input.money') || $('input.money')
      $element.mask('000,000,000,000,000.00', {reverse: true})
      
  @trigger: 
    activate: ->
      $('.trigger').click (event) -> 
        event.preventDefault()
        event.stopPropagation()
        target = $(@).data('target')
        if $(@).data('action') == "modal"
          if target.length 
            url = $(@).data('url')
            if url.length 
              new cork.Modal(target).load url 
        false

  @buttonRadios: 
    activate: ->
      $('[data-toggle="buttons-radio"]').on('click', 'a.btn', (event) -> 
       $target = $(event.currentTarget)
       $target.addClass("active").siblings().removeClass("active");
       window.location = $target.attr('href') 
      )
  @dropdownToggle:
    activate: ->
      $('.dropdown-toggle').dropdown()

  @activate: ->
    @buttonRadios.activate() 
    @dropdownToggle.activate()
    @trigger.activate()

cork.Globals = Globals

Globals.activate()

