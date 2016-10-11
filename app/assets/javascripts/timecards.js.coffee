# timecards.js.coffee
# -------------------

class cork.views.TimecardCalendar extends cork.views.Calendar

  $modal: $('#timecard-modal')
  $add: '#add-timecard-btn'
  $delete: '#delete-timecard-btn'
  events:
    'submit .modal form'         : 'saveEvent'
    'click .geolocate-job-btn'   : 'geolocate'
    'click #add-timecard-btn'    : 'openNewForm'
    'click #delete-timecard-btn' : 'deleteEvent'
    'click .mark-all-btn'        : 'markAllAs'

  geolocate: (e) ->
    e.preventDefault()
    btn = @$('.gelocate-job-btn').addClass('active')
    navigator.geolocation.getCurrentPosition (position)->
      gmapsUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{position.coords.latitude},#{position.coords.longitude}&sensor=false"
      $.get gmapsUrl, {}, (data) =>
        unless data.results[0].formatted_address == undefined
          $.get "/jobs/find_by_address", {address: data.results[0].formatted_address}, (jobId) =>
            helptext = if jobId > 0 then "Job set automatically based on current location" else "Could not find a scheduled job in your current location"
            @$('.geolocate-help-block').html(helptext)
            @$('#timecard_job_id').val(jobId).trigger("liszt:updated")
            btn.removeClass('active')

  visibleEvents: =>
    view = @calendar.fullCalendar 'getView'
    allEvents = @calendar.fullCalendar 'clientEvents'
    visibleEvents = _.filter allEvents, (event) ->
      event.start < view.end and view.start < event.end

  markAllAs: (e) ->
    e.preventDefault()
    state = $(e.target).data('state')
    $('form#mark-all-form input[name=ids]').val(_.pluck(@visibleEvents(), 'id'))
    $('form#mark-all-form input[name=state]').val(state)
    $('form#mark-all-form').submit()

  updateMarkAllState: ->
    anyVisibleEvents = !!@visibleEvents().length
    $('.mark-all-dropdown').toggleClass('disabled', !anyVisibleEvents)

  updateTotals: =>
    visibleEvents = @visibleEvents()
    totalAmount = _.reduce _.pluck(visibleEvents, 'amount'), ((a, b) -> +a + +b), 0
    totalHours = _.reduce _.pluck(visibleEvents, 'duration'), ((a, b) -> +a + +b), 0

    $('#total-hours').text(totalHours)

    if Intl? and Intl.NumberFormat?
      $('#total-amount').text totalAmount.toLocaleString(RAILS_LOCALE,
        {style: 'currency', currency: RAILS_CURRENCY, minimumFractionDigits: 2})
    else
      $('#total-amount').text totalAmount.toFixed(2)

  afterSave: (@event) =>
    super(@event)
    @updateMarkAllState()

  onLoading: (stillWorking, view) =>
    super(stillWorking, view)
    @updateTotals() unless stillWorking
    @updateMarkAllState() unless stillWorking


  onEventSelect: (start, end) =>
    _start = start.local()
    _end = end.local()
    if @isFutureEvent(_end)
      console.log('Future event unselect')
      @unselect()
      return
    _end = end.local()
    _end = @constructor.fixEndDateOffset(_end) if @isCalendarMonthView()
    @lastSelection = { start: _start, end: _end}
    @openNewForm =>
      @setDates(_start, _end)


class cork.views.TimecardSelection extends Backbone.View

  events:
    'change .timecard-select-all' : 'selectAll'
    'change .timecard-selected'   : 'updateSelection'
    'click .mark-all-btn'         : 'markAllAs'

  selectAll: (e) ->
    checked = $(e.target).is(':checked')
    $('.timecard-selected').prop('checked', checked).trigger('change')

  allChecked: ->
    allChecked = $('.timecard-selected:checked').length == $('.timecard-selected').length

  anyChecked: ->
    anyChecked = !!$('.timecard-selected:checked').length

  updateSelectAllState: ->
    $('.timecard-select-all')
      .prop('checked', @anyChecked())
      .prop('indeterminate', @anyChecked() and !@allChecked())

  updateMarkAllState: ->
    $('.mark-all-dropdown').toggleClass('disabled', !@anyChecked())

  updateSelection: (e) ->
    @updateSelectAllState()
    @updateMarkAllState()
    # Highlight the row if selected.
    checked = $(e.target).is(':checked')
    $(e.target).parents('tr').toggleClass('warning', checked)

  getSelectedIds: ->
    $('.timecard-selected:checked').map(-> $(this).data('id')).get()

  markAllAs: (e) ->
    e.preventDefault()
    state = $(e.target).data('state')
    $('form#mark-all-form input[name=ids]').val(@getSelectedIds())
    $('form#mark-all-form input[name=state]').val(state)
    $('form#mark-all-form').submit()

fetchEvents = (start, end, timezone, callback) ->
  params =
    start: start.unix()
    end:   end.unix()
    _:     moment().unix()

  stateFilter = $('#timecards-state-filter .active').data('value')
  staffFilter = $('#timecards-staff-filter').data('value')
  params.filter = stateFilter if stateFilter
  params.staff = staffFilter if staffFilter
  $.get '/jobs/timecards.json', params, callback

$ ->
  if $('#timecards-calendar-ibox').length
    new cork.views.TimecardCalendar
      el: $('#timecards-calendar-ibox')
      modelName: 'Timecard'
      newForm: '/jobs/timecards/modal_form'
      editForm: (id) -> "/jobs/timecards/#{id}/modal_form"
      calendar:
        firstHour: 8
        defaultView:'agendaWeek'
        events: fetchEvents

  if $('#timecards-list-ibox').length
    new cork.views.TimecardSelection
      el: $('.row-fluid')

  if $('form.edit_timecard').length
    new cork.views.TimecardCalendar
      el: $('form.edit_timecard')

  $('#timecard_start_datetime').change (e)-> $('#timecard_end_datetime').val($(@).val()) if $('#timecard_end_datetime').val() == ""

$("input[id^='timecard'][type='datetime_picker']").datetimepicker({
  dateFormat: 'm/d/yy'
  timeFormat: 'h:mm tt'
  controlType: 'select'
  stepMinute: 15
  hour: 9
  maxDate: new Date()
  hourMin: 6
  hourMax:21
  minuteMax:61
});
