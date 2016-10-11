# appointments.js.coffee
# ----------------------

class cork.views.AppointmentCalendar extends cork.views.Calendar
  $modal: $('#appointments-modal')
  $add: '#add-appointment-btn'
  $delete: '#delete-appointment-btn'
  events:
    'click .appointment-employee-filter' : 'filterAppointments'
    'click #open-export-modal': 'exportCalendar'
    'click #open-google-calendars-modal': 'googleCalendarSettings'

  exportCalendar: ->
    $('#export-modal').modal 'show'

  googleCalendarSettings: ->
    $('#google-calendars-modal').modal 'show'

  filterAppointments: (e) ->
    setTimeout (=> @calendar.fullCalendar('refetchEvents')), 0

  onEventRender: (event, element) =>
    $(element).removeClass('slotted-event')
    $(element).addClass('slotted-event') unless event.jobId? or event.from_google?
    if event.from_google?
      $(element).removeClass('fc-resizable')
      $(element).removeClass('fc-draggable')
      $(element).tooltip({title: event.title, container: "body"})

  initialize: ->
    @openNewForm() if window.location.href.indexOf("add_to_job")>-1
    super


$ ->
  if $('#appointments-calendar-ibox').length
    new cork.views.AppointmentCalendar
      el: $('#appointments-calendar-ibox')
      modelName: 'Appointment'
      newForm: "/appointments/modal?#{window.location.href.split("?")[1]}"
      editForm: (id) -> "/appointments/#{id}/modal"
      startEndSameDay: true
      calendar:
        maxTime: {hours:22 }
        hourMin: 6
        height: 'auto'
        defaultAllDayEventDuration: {hours:16}
        defaultView: if window.innerWidth > 500 then 'agendaWeek' else 'agendaDay'
        events: (start, end, timezone, callback)->
          who = $('.appt-who-filter .active').data('value')
          employees = $.map($('.appointment-employee-filter.active'),(value,index)-> $(value).data("id")).join(",")
          start = start.unix()
          end = end.unix()
          seconds = Math.round(new Date().getTime()/1000)

          $.get "/appointments.json", {who: who, employees: employees, start: start, end: end, _: seconds}, (appointments) ->
            events = []
            $.each(appointments, (_, appt) ->
              appt.start = moment(appt.start)
              appt.end = moment(appt.end)
              events.push appt
            )
            callback(events)

  $('.appt-who-filter .btn').click (e)->
    e.preventDefault()
    btn = $(@)
    val = btn.data('value')
    switch val
      when "everyone", "owner"
        $('.appointment-filters').hide 400, ->
          $('#appointments-calendar-ibox').fullCalendar("refetchEvents")
      when "employees"
        $('.appointment-filters').show 400, ->
          $('#appointments-calendar-ibox').fullCalendar("refetchEvents")
    window.location = btn.attr('href')

  $(window).on 'load', ->
    $('.modal').on 'shown.bs.modal', ->
      $('.chzn-select').chosen();
      contact = $('#appointment_job_id option:selected').val()+"_hidden_contact"
      contact = $('#'+contact).data('contact')
      if(contact)
        $('#contact_rating_contact_id').val(contact)
        $.ajax 'appointments/get_contact_rating',
          type: 'GET'
          dataType: 'text',
          data: {'contact':contact, 'stage':'Appointment'},
          error: (jqXHR, textStatus, errorThrown) ->
            console.log('something went wrong')
          success: (data, textStatus, jqXHR) ->
            $('#contact_rating_rating_id').val(data)
            $('.customer_rating').fadeIn()


  $('#google_settings_form').submit (e) ->
    if($(this).find("input:checked").length == 0)
      $(this).find("#error_message").html("<div style='color:red; margin-left:10px;'><i>" + "You must select at least one calendar." + "</div>")
      return false

$ ->
  $(document).on "change", "#appointment_job_id", ->
    contact = $('#appointment_job_id option:selected').val()+"_hidden_contact"
    contact = $('#'+contact).data('contact')
    if(contact)
      $('.customer_rating').fadeIn()
      $('#contact_rating_contact_id').val(contact)
    else
      $('.customer_rating').fadeOut()
      $('#contact_rating_contact_id').val('')
      $('#contact_rating_rating_id').val('')