class Job
  index: ->
    $('.trigger-popover').hover( () -> 
      $(@).trigger('click')
    )
    $('.schedule-entries').scrollTop(0)
    cork.Communication.Notes.activate()
    $('#new-invoice-modal').on('shown.bs.modal', -> 
      $modal = $(@)
      $alert = $modal.find('.alert')
      cork.Globals.inputMask.money($modal)
      $max_value_error = $modal.find('#max-value-error')
      $send_invoice = $modal.find('#send-invoice')
      disable = (el) ->
        $(el).prop('disabled', true)
      enable = ($el) ->
        $el.prop('disabled', false)  
      disable($send_invoice)   
      $input_amount = $modal.find('input#amount')
      toFloat = (str) ->
        parseFloat(str.replace(/,/,''))
      max_invoice = toFloat($input_amount.data('max-value') || 0) 
      input_invoice_amount = -> 
       toFloat($input_amount.val()) || 0
      $description = $modal.find('input#description')
      $input_amount.on("keyup blur", () ->
        invoice_amount = input_invoice_amount()
        if invoice_amount > max_invoice
          $max_value_error.show()
          disable($send_invoice)   
        else 
         $max_value_error.hide()
         if invoice_amount > 0   
          enable($send_invoice)  
         else 
          disable($send_invoice)     
      )
      $send_invoice.click( ->
       amount = input_invoice_amount()
       description = $description.val()
       if amount > 0
         job_id = $(@).data('jobId')
         $send_invoice.spin()
         $.ajax(
            url: "/jobs/#{job_id}/send_invoice"
            method: 'POST'
            data: 
              amount: amount
              description: description
            success: () ->
              $modal.modal('hide')
              alertify.success("Your invoice has been sent successfully.") 
          ).fail((response) -> 
            if response.responseJSON.error == "qb_authorization"
              $alert.find('.content').html("Quick Books Authorization Failed.  You may try to reconnect and try again.")
          ).always( () -> 
            $send_invoice.spin(false)
          )    
      )
    )
  schedule: ->
    new cork.Filters().activate(".calendar-filters")

cork.Job = Job