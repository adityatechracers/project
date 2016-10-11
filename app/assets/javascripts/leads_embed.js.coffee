_.mixin(_.str.exports())

class cork.views.AppointmentEmbedCalendar extends cork.views.Calendar
  events:
    'submit .modal form'            : 'saveEvent'
    'click #delete-appointment-btn' : 'deleteEvent'
    'click #add-appointment-btn'    : 'openNewForm'
    'change .appointment-filter'    : 'filterAppointments'

  filterAppointments: (e) ->
    if $(e.currentTarget).is(':checked')
      @calendar.fullCalendar('refetchEvents')
    else
      id = $(e.currentTarget).data('id')
      @calendar.fullCalendar('removeEvents', (event) -> id == event.userId)

  onEventRender: (event, element) =>
    $(element).removeClass('slotted-event')
    $(element).addClass('slotted-event') unless event.jobId?

  openNewForm: (cb) =>
    cb() if cb instanceof Function

  openEditForm: (cb) =>
    window.event_in_question = @event
    $('#appointment_id_field').val(@event.id)
    $('.title').html("Book an appointment for #{@event.start_text}")
    $('#appointments-embedded-calendar-widget .calendar').hide "slide", {direction:'up'}, 400, ->
      $('#embedded-new-appointment-form').show 400, -> cb() if cb instanceof Function

  afterSave: (cb) =>
    $('#embedded-new-appointment-form').hide 400, ->
      $('.title').html(window.widget_title)
      $('#appointments-embedded-calendar-widget .calendar').show "slide", {direction:'up'}, 400, ->
        $('.calendar').fullCalendar('removeEvents', window.event_in_question.id)
        cb() if cb instanceof Function

  setDates: (start, end) ->
    @$('input.datetime_picker').corkDatetimePicker(cork.datetimePickerDefaults)
    @$('form input[id*=start_datetime]').corkDatetimePicker('setDate', start.toDate())
    @$('form input[id*=end_datetime]').corkDatetimePicker('setDate', end.toDate())

$ ->
  notify = (notify_type, msg) ->
    a = $('<div />').insertAfter($('.nav.nav-tabs')).html(msg)
    $('<a class="close" data-dismiss="alert" href="#">×</a>').prependTo(a)
    a.addClass('alert-block') if msg.match /<[^>]*>/
    a.addClass('alert alert-success').fadeIn('fast') if (notify_type == 'success')
    a.addClass('alert alert-error').fadeIn('fast') if (notify_type == 'failure')
    $('html, body').animate { scrollTop: 0 }, "slow"

  w = $('#appointments-embedded-calendar-widget')
  if w.length
    window.view = new cork.views.AppointmentEmbedCalendar
      el: w
      modelName: 'Appointment'
      newForm: '/appointments/modal'
      editForm: (id) -> "/appointments/#{id}/modal"
      calendar:
        defaultView: 'agendaWeek'
        events: "/appointments/fetch_open?embedded=true&org="+w.attr('data-org')
        editable: false
        disableDragging: true
        selectable: false

  $('#embed_schedule_form').submit (e)->
    errors = {}
    $('input.required').each ->
      unless $(@).val().length
        $(@).css('border-color', 'red')
        errors[$(@).attr('id')] = 'cannot be left blank'
    unless $.isEmptyObject(errors)
      msg = '<h4>The following errors prevented your appointment from being saved:</h4>'
      msg += '<ul>'
      msg += _.map(errors, (error, id)->
        "<li>#{_(id).chain().humanize().titleize().value()} #{error}</li>").join('')
      msg += '</ul>'
      notify 'failure', msg
      return false
    window.view.afterSave ->
      $('#embedded-thank-you').show()

  $('#embed_ask_questions_form').submit (e)->
    errors = {}
    $('input.required').each ->
      unless $(@).val().length
        $(@).css('border-color', 'red')
        errors[$(@).attr('id')] = 'cannot be left blank'
    unless $.isEmptyObject(errors)
      msg = '<h4>The following errors prevented your appointment from being saved:</h4>'
      msg += '<ul>'
      msg += _.map(errors, (error, id)->
        "<li>#{_(id).chain().humanize().titleize().value()} #{error}</li>").join('')
      msg += '</ul>'
      notify 'failure', msg
      return false
    $('#embedded-thank-you').show()
    $(@).hide()

$ ->
  $('#embed_ask_questions_form').on('ajax:success', (e, data, status, xhr) ->
    $('#embedded-thank-you').attr("style", "display: block !important")
    return
  ).on 'ajax:error', (e, xhr, status, error) ->
    $('#embedded-danger-you .content').html(error+'. '+JSON.parse(xhr.responseText).error)
    $('#embedded-danger-you').attr("style", "display: block !important")
    return


  window.widget_title = $('.title').html()
