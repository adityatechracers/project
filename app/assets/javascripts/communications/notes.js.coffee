class Notes 
  @activate: -> 
    $(document).on('ajax:success','#new_communication' , (_, response) ->
      $template = $(response.template)
      $table = $(@).parent().parent().parent().find('#communication-history-table table').first()
      $table.remove('.empty').prepend($template)
      $template.animateCss('fadeInRight')
      $('.note_text').val('')
      $('textarea.text').val('')
    )

cork.Communication.Notes  = Notes