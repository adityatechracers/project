class Dashboard
  index: -> 
    $.ajax 'get_leads_stats',
      type: 'GET'
      dataType: 'text',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('something went wrong')
      success: (data, textStatus, jqXHR) ->
        $('.leads_stats').html(data)

    $.ajax 'get_proposals_stats',
      type: 'GET'
      dataType: 'text',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('something went wrong')
      success: (data, textStatus, jqXHR) ->
        $('.prposals_stats').html(data)

    $.ajax 'get_jobs_stats',
      type: 'GET'
      dataType: 'text',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('something went wrong')
      success: (data, textStatus, jqXHR) ->
        $('.jobs_stats').html(data)

    $.ajax 'get_sales_stats',
      type: 'GET'
      dataType: 'text',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('something went wrong')
      success: (data, textStatus, jqXHR) ->
        $('.sales_stats').html(data)

    $.ajax 'get_footer',
      type: 'GET'
      dataType: 'text',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('something went wrong')
      success: (data, textStatus, jqXHR) ->
        $('.dashboard_footer').html(data)
        
cork.Dashboard = Dashboard
