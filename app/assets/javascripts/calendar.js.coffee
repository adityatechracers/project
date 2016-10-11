# calendar.js.coffee
# ------------------

cork.views ||= {}

class cork.views.Calendar extends Backbone.View
  # TODO: If there's time, this could be reworked to use Backbone.Model and
  # Backbone.Collection, but I started with a simple approach.

  @defaults:
    time:
      START: 8
      END: 17

  calendarDefaults:
    selectable: true
    selectHelper: true
    minTime: { hours: 6 }
    height: 'auto'
    aspectRatio: 1.45
    header:
      left: 'today prev,next'
      center: 'title'
      right: 'month,agendaWeek,agendaDay'
    editable: true
    lazyFetching: false
    lang: RAILS_LOCALE

  initialize: (options) ->
    @options.calendar = _.extend({}, @calendarDefaults, options.calendar)
    @setupCalendar()
    @setupModal()
    $target = @$el
    if @$el.find('input.datetime_picker').length == 0
      $target = @$modal

  setupModal: =>
    @constructor._$modal = @$modal
    @startDate = null
    @endDate = null
    @$modal.on('shown.bs.modal', (event) =>
      $modal = @$modal
      @startDate = $modal.find('input.start_datetime')
      @endDate = $modal.find('input.end_datetime')
      @startDate.corkDatetimePicker(cork.datetimePickerDefaults)
      @endDate .corkDatetimePicker(cork.datetimePickerDefaults)
      startDate = moment(@startDate.datetimepicker('getDate'))
      endDate = moment(@endDate.datetimepicker('getDate'))
      hourAfterStart = startDate.startOf('hour').add(1, 'hour')
      setEndDateAfterStart = =>
        @endDate.datetimepicker('setDate', hourAfterStart.toDate())
      console.log startDate

      if startDate._isValid
        if startDate.isAfter(endDate) || startDate.isSame(endDate)
          setEndDateAfterStart()
        else if @options.startEndSameDay && !moment(startDate).endOf('day').isSame(endDate.endOf('day'))
          setEndDateAfterStart()
    )
    @$modal.on('submit', 'form', (event) =>
      @saveEvent(event)
    )
    $(@$add).click((event) =>
      @openNewForm(event)
    )
    @$modal.on('click', @$delete, (event) =>
      @deleteEvent(event)
    )

  moment: (inputDateTime) ->
    console.log('getDate', inputDateTime.datetimepicker('getDate'))
    moment(inputDateTime.datetimepicker('getDate'))

  setupCalendar: ->
    eventHandlers =
      select:      @onEventSelect
      eventClick:  @onEventClick
      eventDrop:   @onEventMove
      eventResize: @onEventMove
      eventRender: @onEventRender
      loading:     @onLoading
    options = _.extend(@options.calendar, eventHandlers)
    @$calendar = @$('.calendar')
    $('.loading-indicator').clone().appendTo(@$calendar)
    @calendar = @$calendar.fullCalendar options

  setupChosen: ->
    $('.chzn-select').corkChosen(allow_single_deselect: true)

  modal: (option) =>
    @$modal.modal option

  formatDate: (d) ->
    month = d.getMonth() + 1
    date = d.getDate()
    year = d.getFullYear()
    "#{month}/#{date}/#{year}"

  @hour: (date, defaultHour) ->
    hour = date.hours()
    hour = defaultHour if hour == 0
    hour
  @setStartDate: (start) ->
    start.set("hour", @hour(start, cork.views.Calendar.defaults.time.START))

  @setEndDate: (end) ->
    end.set("hour", @hour(end, cork.views.Calendar.defaults.time.END))

  @isStartOfDay: (date) ->
    date.isSame(date.startOf('day'))

  @isStartOfDay: (date) ->
    date.isSame(date.startOf('day'))

  @setDates: ($el, start, end) ->
    $el.find('input.datetime_picker').corkDatetimePicker cork.datetimePickerDefaults
    $start = $el.find('form input[id*=start_date]')
    $end = $el.find('form input[id*=end_date]')

    if start
      @setStartDate(start)
      $start.corkDatetimePicker('setDate', start.toDate())
    else
      $start.val('')

    if end
      @setEndDate(end)
      $end.corkDatetimePicker('setDate', end.toDate())
    else
      $end.val('')

  isCalendarMonthView: =>
    @calendar.fullCalendar('getView').name == "month"

  @isAmbiguousDate: (date) =>
    date.isSame(date.startOf('day'))

  @fixEndDateOffset: (end) ->
    #remove extra day (24hours) fullcalendar adds for ambiguous time
    if @isAmbiguousDate(end)
      end.set("hour", -24)
    else
      end

  setDates: (start, end=null) =>
    @constructor.setDates($('body'), start, end)

  @saveEvent: (event, success, error, options) ->
    event.preventDefault()  if event
    $el = @._$modal
    $el = $(options.el) if options.el
    $form = $el.find('form')
    data = []
    $.each($form.serializeArray(), (_, input_data) =>
      if input_data.name.match(/start_datetime|end_datetime/)
        input_data.value = moment(new Date(input_data.value)).format('MM/DD/YYYY h:mm a')
      data.push input_data
    )
    $.ajax
      url: $form.attr('action')
      data: $.param(data)
      dataType: 'JSON'
      method: if !_.isNull(options.id) then 'PUT' else 'POST'
      success: success
      error: error

  saveEvent: (e) =>
    id = null
    id = @event.id if @event
    @message("")
    if ($('input.start_datetime').val() == "") || ($('input.end_datetime').val() == "")
      @message("<div style='color:red'><i>Time fields can not be empty</div>")
      return false
    invalid_dates = null
    if (@startDate && @startDate.datetimepicker('getDate')) && (@endDate && @endDate.datetimepicker('getDate'))
      invalid_dates = @moment(@startDate).isAfter(@moment(@endDate)) || @moment(@startDate).isSame(@moment(@endDate))
    else
      invalid_dates = @event._start.isAfter(@event._end) || @event._start.isSame(@event._end)

    if invalid_dates
      e.preventDefault() if e
      @message("<div style='color:red'><i>End date time must be after start date time</div>")
      return false
    else
      @constructor.saveEvent e, @afterSave, @onFailedSave, {id:id}

  @deleteEvent: (event, success, options, error) ->
    event.preventDefault()
    return unless window.confirm "Are you sure you want to delete this #{options.name}?"
    $el = @._$modal
    if(!$el?)
      $el = options.el
    $form = $el.find('form')
    $.ajax
      url: "#{$form.attr('action')}.json"
      method: 'DELETE',
      success:success
      error: error

  deleteEvent: (e) =>
    @constructor.deleteEvent e, @afterDelete, {name:@options.modelName.toLowerCase()}

  openNewForm: (cb) ->
    @event = null
    @$modal.load @options.newForm, =>
      @modal 'show'
      cb() if cb instanceof Function

  openEditForm: ->
    @$modal.load @options.editForm(@event.id), =>
      @modal 'show'

  onEventClick: (@event) =>
    @openEditForm() unless @event.from_google?

  onEventMove: (@event, _, revert) =>
    _start = @event.start.local()
    _end = @event.end.local()
    if (@isPastEvent(_start) && !@event.can_be_past?) || @event.from_google?
      revert()
    else
      @$modal.load @options.editForm(@event.id), =>
        @setDates(_start, _end)
        @saveEvent()

  isPastEvent: (start) ->
    now = moment().local().startOf('day')
    return start.isBefore(now)

  isFutureEvent: (end) ->
    now = moment().local().endOf('day')
    return end.isAfter(now)

  unselect: =>
    @$calendar.fullCalendar('unselect')

  onEventSelect: (start, end) =>
    _start = start.local()

    if @isPastEvent(_start)
      console.log('past event unselect')
      @unselect()
      return

    _end = end.local()
    _end = @constructor.fixEndDateOffset(_end) if @isCalendarMonthView()
    @lastSelection = { start: _start, end: _end}
    @openNewForm =>
      @setDates(_start, _end)

  onLoading: (stillWorking, view) =>
    @$calendar.find('.fc-view-container').css(opacity: if stillWorking then 0.3 else 1.0)
    @$('.loading-indicator').toggle(stillWorking)

  message: (content) =>
    @$modal.find('.messages').html(content)

  @onFailedSave: (res, @$modal) =>
    @$modal.modal 'show'
    $modal.find("#job_error_notification").html("<div style='color:red; margin-left:190px;'><i>" + res.responseText + "</div>")
    @message(res.responseText)

  onFailedSave: (res) =>
    @constructor.onFailedSave res, @$modal
    @calendar.fullCalendar 'refetchEvents'

  @afterSave: (modal) ->
    modal 'hide'
    alertify.success("All changes saved.")

  afterSave: (@event) =>
    @calendar.fullCalendar('removeEvents', @event.id)
    @event.start = moment(@event.start)
    @event.end = moment(@event.end)
    @calendar.fullCalendar('renderEvent', @event)
    @constructor.afterSave @modal

  @afterDelete: (modal) ->
    modal 'hide'
    alertify.success("All changes saved.")

  afterDelete: =>
    @calendar.fullCalendar 'refetchEvents'
    @event = null
    @constructor.afterDelete @modal
