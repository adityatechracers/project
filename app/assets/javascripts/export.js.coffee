class Export
  constructor: ({@source, @location}) ->

  checkCookie: (tries, spinner) =>
    tries = tries + 1
    cookieVal = Cookies.get('exportFinished')
    funcWithArg = => @checkCookie(tries, spinner)
    if tries < 30 && (cookieVal == null || cookieVal == undefined)
      setTimeout(funcWithArg, 1000)
    else
      Cookies.remove('exportFinished')
      $('#waiting-download').hide()
      $('#spinner').hide()
      $('#cancel-data-button').prop('disabled', false)
      @spinner.stop()
      $('#export-data-button').prop('disabled', false)
      if tries < 30
        $('#success-download').show()
      else
        $('#failure-download').show()

  init: -> 
    $modal = $($(@source).data('modal'))
    $modal.find('#export-data-button').prop('disabled',false).click (event) => 
      $(event.currentTarget).prop('disabled', true)
      $cancel = $modal.find('#cancel-data-button')
      $cancel.prop('disabled', true)
      $content = $modal.find('#modal-content')
      $content.hide()
      $waiting = $modal.find('#waiting-download')
      $waiting.show()
      target = document.getElementById('spinner')
      @spinner = new Spinner().spin(target);
      $('#spinner').show()
      window.location.href = @location
      @checkCookie(0, spinner)

      $cancel.click (e)->
        $content.show()
        $waiting.hide()
        $modal.find('#success-download').hide()
        $modal.find('#failure-download').hide()

cork.Export = Export   