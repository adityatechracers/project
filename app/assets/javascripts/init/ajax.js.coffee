$.ajaxSetup(
  dataType: 'json',
  converters: 
    "text json": (response) ->
      json = $.trim(response)
      if json.length != 0
        jQuery.parseJSON(json)
      else
        return
  
)