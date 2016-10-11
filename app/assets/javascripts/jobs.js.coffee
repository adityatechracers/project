# jobs.js.coffee
# --------------

class cork.views.CrewCalendar extends Backbone.View
  events:
    'change .crew-filter'       : 'filterCrews'

  initialize: (options) ->
    super(options)
    @initFilters()

  filterCrews: (e) ->
    id = $(e.currentTarget).data('id')
    checked = $(e.currentTarget).is(':checked')
    sessionFilter = JSON.parse(sessionStorage['crew_calendar'])

    if $('.crew-filter:not(:checked):not([data-id=all-crews])').size() > 0
      $('.crew-filter[data-id=all-crews]').prop('checked', false)
    else
      $('.crew-filter[data-id=all-crews]').prop('checked', true)

    if id == 'all-crews'
      for k,v of sessionFilter
        sessionFilter[k] = checked
      $('.crew-filter').prop('checked', checked)
      this.$('tr[data-id]').toggle(checked)
      this.$("tr:not([data-id])").toggle(checked)
      sessionStorage['crew_calendar'] = JSON.stringify(sessionFilter)
      return

    sessionFilter[id] = checked
    sessionStorage['crew_calendar'] = JSON.stringify(sessionFilter)

    this.$("tr[data-id=#{id}]").toggle(checked)
    this.$("tr:not([data-id])").toggle(checked) unless id

  initFilters: ->
    if !sessionStorage['crew_calendar']?
      filters = $(".crew-filter")
      filterTracker = {}
      filters.each (index, filter) ->
        id = $(filter).attr('data-id')
        filterTracker[id] = true

      $("tr[data-id]").toggle(true)
      $("tr:not([data-id])").toggle(true)
      sessionStorage['crew_calendar'] = JSON.stringify(filterTracker)
    else
      sessionFilter = JSON.parse(sessionStorage['crew_calendar'])
      filters = $(".crew-filter")
      filters.each (index, filter) ->
        id = $(filter).attr('data-id')
        $(filter).prop('checked', sessionFilter[id])
        $("tr[data-id-#{id}]").toggle(sessionFilter[id])
        $("tr:not([data-id])").toggle(sessionFilter[id]) unless id

      if $('.crew-filter:not(:checked)').size() > 0
        $('.crew-filter[data-id=all-crews]').prop('checked', false)

    $('#filters').show()

class cork.views.JobCalendar extends cork.views.Calendar
  $modal: $('#job-calendar-modal')
  $add: '#add-job-btn'
  $delete: '#unschedule-job-btn'
  events:
    'change .crew-filter'        : 'filterCrews'
    'change .unscheduled-filter' : 'filterUnscheduled'

  initialize: (options) ->
    super(options)
    @initColorPickers()

  filterCrews: (e) ->
    if $(e.currentTarget).is(':checked')
      @calendar.fullCalendar('refetchEvents')
    else
      @removeFilteredCrews()

  filterUnscheduled: (e) ->
    if $(e.currentTarget).is(':checked')
      @calendar.fullCalendar('refetchEvents')
    else
      @removeUnscheduled()

  removeFilteredCrews: ->
    ids = $('.crew-filter:not(:checked)').map(-> $(this).data('id')).get()
    @calendar.fullCalendar('removeEvents', (event) -> !event.unscheduled and (event.crewId or 0) in ids)

  removeUnscheduled: ->
    unless $('.unscheduled-filter').is(':checked')
      @calendar.fullCalendar('removeEvents', (event) -> event.unscheduled)

  onEventClick: (@event) =>
    if @event.unscheduled
      newForm = @options.newForm
      @options.newForm += "?job=#{@event.jobId}"
      @openNewForm()
      @options.newForm = newForm
    else
      @openEditForm()

  onEventRender: (event, element) ->
    if event.touchUp
      label = $('<span>', { class: 'label event-tag' }).text('Touch Up')
      element.find('.fc-content').append(label)
    if event.hasNotes
      label = $('<span>', { class: 'label event-tag' }).text('Notes')
      element.find('.fc-content').append(label)
    if event.unscheduled
      label = $('<span>', { class: 'label event-tag' }).text('Unscheduled')
      element.find('.fc-content').append(label)
    element

  afterSave: (@event) =>
    super(@event)
    # Need to refresh events because it's possible an unscheduled job is now scheduled.
    @calendar.fullCalendar('refetchEvents')

  onLoading: (stillWorking, view) =>
    super(stillWorking, view)
    unless stillWorking
      @removeUnscheduled()
      @removeFilteredCrews()

   updateCrewColor: _.debounce((crewId, color)->
    $.ajax
      url: "/manage/crews/#{crewId}"
      data: {crew: {color: color}}
      dataType: 'JSON'
      method: 'PUT',
      success: (crew) =>
        @calendar.fullCalendar('refetchEvents')
  , 500)

  initColorPickers: ->
    colorPicker = $('.filter-color-crew').colorpicker({format: 'hex'})
    colorPicker.on 'changeColor', (event) =>
      elem = $(event.currentTarget);
      elem.css('background-color', event.color.toHex())
      @updateCrewColor(elem.data('id'), event.color.toHex())

$ ->
  if $('#job-calendar-ibox').length
    new cork.views.JobCalendar
      el: $('#job-calendar-ibox')
      modelName: 'Entry'
      newForm: '/job_schedule_entries/modal'
      editForm: (id) -> "/job_schedule_entries/#{id}/modal"
      calendar:
        events: '/job_schedule_entries.json'

  if $('#crew-calendar-ibox').length
    new cork.views.CrewCalendar
      el: $('#crew-calendar-ibox')

  if (csf=$('#jobs_search_field')).is('*')
    delay = 500
    timer = null
    tbody = $('#jobs_table tbody')
    csf.on "input", (e)->
      tbody.html("").append($('<tr />').append($('<td />').attr('colspan',7).css({"text-align":"center","font-style":"italic","color":"#666666"}).html("Loading...")))
      clearTimeout(timer) if timer?
      timer = setTimeout (-> loadSearchResults()), delay

  loadSearchResults = ->
    tbody.load("/jobs/table"+window.location.search, {query:csf.val()}, ->
      timer = null
      bindCommunicationEvents()
    )

  setDefaultCrewForJob = ->
    return unless $('#new_job_schedule_entry').length
    crewId = $('#job_schedule_entry_job_id option:selected').data('crew-id')
    $('#job_schedule_entry_crew_id').val(crewId).trigger('liszt:updated').trigger('change')

  updateDefaultCrewOption = ->
    return unless $('#job_schedule_entry_job_id').length
    defaultCrewId = $('#job_schedule_entry_job_id option:selected').data('crew-id')
    crewId = parseInt $('#job_schedule_entry_crew_id').val(), 10

    $('#job_schedule_entry_make_default_crew').removeAttr('checked')
    if crewId == defaultCrewId or !crewId
      $('.make-default-crew-wrapper').hide()
    else
      $('.make-default-crew-wrapper').show()

  updateTimeframe = ->
    return unless $('#job_schedule_entry_job_id').length
    timeframe = $('#job_schedule_entry_job_id option:selected').data('timeframe')
    if timeframe
      $('#job-expected-timeframe').text(timeframe)
      $('.job-expected-timeframe-wrapper').show()
    else
      $('.job-expected-timeframe-wrapper').hide()

  checkSpecificJobInitiate = ->
    if $('#j_p_i').val()
      $('#job_schedule_entry_job_id').val($('#j_p_i').val())
      $("select#job_schedule_entry_job_id option[value='"+$('#j_p_i').val()+"']").attr("selected","selected");

  $(document)
    .on('load change', '#job_schedule_entry_job_id', setDefaultCrewForJob)
    .on('load change', '#job_schedule_entry_job_id', updateTimeframe)
    .on('load change', '#job_schedule_entry_crew_id', updateDefaultCrewOption)

  $('#job-calendar-modal')
    .on('show.bs.modal', setDefaultCrewForJob)
    .on('show.bs.modal', updateDefaultCrewOption)
    .on('show.bs.modal', updateTimeframe)
    .on('show.bs.modal', checkSpecificJobInitiate)

  updateDefaultCrewOption()
  updateTimeframe()

$ ->
  if $('#j_p_i').val()
    $('#add-job-btn').trigger('click')