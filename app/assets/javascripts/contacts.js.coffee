if $('#contacts-page').length  
  $(document).on('ajax:success','#new_communication' , (_, response) ->
    $template = $(response.template)
    $table = $(@).parent().parent().parent().find('#communication-history-table table').first()
    $table.remove('.empty').prepend($template)
    $template.animateCss('fadeInRight')
    $('.note_text').val('')
    $('textarea.text').val('')
  )

jQuery ->
  if (csf=$('#contact_search_field')).is('*')
    delay = 500
    timer = null
    tbody = $('#contacts_table tbody')
    csf.on "input", (e)->
      tbody.html("").append($('<tr />').append($('<td />').attr('colspan',5).css({"text-align":"center","font-style":"italic","color":"#666666"}).html("Loading...")))
      clearTimeout(timer) if timer?
      timer = setTimeout (-> tbody.load("/contacts/table", {query:csf.val()}, -> timer = null)), delay

  new cork.Export(source: '#export-contacts', location:'/contacts/export').init()
