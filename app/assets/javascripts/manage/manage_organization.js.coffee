class ManageOrganization
  edit: ->
    $disconnect = $('#disconnect-from-qb')
    $disconnect.click((event) ->
      event.stopPropagation()
      self = this
      if confirm("Are you sure?") 
        $disconnect.spin()
        $.ajax(
          url: '/quick_books/disconnect'
          method: 'DELETE'
          success: () ->
            $disconnect.spin('false')
            $(self).hide()
            $('#qb-action #connect').fadeIn()
            alertify.success("You have disconnected quick books successfully.") 
        )   
      false   
    )
cork["Manage::Organization"] = ManageOrganization  