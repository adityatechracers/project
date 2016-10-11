$ ->
  $(document).on "click", "#availability-arrow-left,#availability-arrow-right", ->
    $.ajax $(this).data('link'),
      type: 'GET'
      dataType: 'text'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('something went wrong')
      success: (data, textStatus, jqXHR) ->
        $('.availability_days_wrapper').html data

$ ->
  $(document).on "click", ".availability-day-button", ->
    $.ajax $(this).data('link'),
      type: 'GET'
      dataType: 'text'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('something went wrong')
      success: (data, textStatus, jqXHR) ->
        $('.available_employees_wrapper').html data

$ ->
  $(document).on "click", "#availability-employees-back,#availability-employees-forward", ->
    $.ajax $(this).data('link'),
      type: 'GET'
      dataType: 'text'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('something went wrong')
      success: (data, textStatus, jqXHR) ->
        $('.available_employees_wrapper').html data

$ ->
  $(document).on "click", "#new-appointment-btn,#appointment-box", ->
    $.ajax $(this).data('link'),
      type: 'GET'
      dataType: 'text'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('something went wrong')
      success: (data, textStatus, jqXHR) ->
        $('#appointment-modal').html data
        $("#appointment-modal").modal()
        $("#appointment-modal").find('.chzn-select').chosen()
        $('#appointment_form').submit (e) ->
          start = $('input.start_datetime').val()
          end = $('input.end_datetime').val()
          if (start == "") || (end == "")
            $(".messages").html("<div style='color:red'><i>Time fields can not be empty.</div>")
            return false
          if (Date.parse(start) < new Date()) || (Date.parse(start) < new Date())
            $(".messages").html("<div style='color:red'><i>Past times are not valid.</div>")
            return false
          if Date.parse(start) > Date.parse(end)
            $(".messages").html("<div style='color:red'><i>End time must be after start time.</div>")
            return false

$(".availability-day-button").click (e)->
  $(".availability-day-button").removeClass('active-day')
  $(this).addClass('active-day')
