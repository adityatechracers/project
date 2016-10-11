ordered_template_ids = []
$ -> $('.et-deactivate-btn').click (e)-> $(@).toggleClass('active')

$(".sortable").sortable
  axis:"y"
  stop:(e,ui) ->
  	ordered_template_ids.length = 0
  	$(ui.item).parent().find('tr').each -> 
  		ordered_template_ids.push $(this).attr('data-template-id')
	  $.ajax
		  data: {ordered_template_ids: ordered_template_ids}
		  type: 'POST'
		  url: '/admin/email_templates/sort_email_templates'   

        