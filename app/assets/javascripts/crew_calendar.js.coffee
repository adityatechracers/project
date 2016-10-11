jQuery ->

  $calendar = $('#crew-calendar-ibox')

  $modal = null
  weekStart = weekEnd = null
  weekOffset = null
  afterUpdate = (crew, startDate, done, error) ->
    crew_id = ""
    if crew
      crew_id = crew
    inCurrentWeek = startDate.isBetween(weekStart, moment(weekEnd).add(1,'d'), null, '[)')
    if !inCurrentWeek
      done()
      return
    $.get("/jobs/crew_calendar_row?crew_id=#{crew_id}&week=#{weekOffset}", (response) ->
      $html = $(response)
      $html.removeClass('hide')
      $("#crew-#{crew_id}").replaceWith($html)
      done() if done
    , 'html').fail(error)

  options =
    afterSave: afterUpdate
    afterDelete: afterUpdate

  $modal = new cork.JobCalendarModal($calendar.find('.modal'), options)

  date = (rails) ->
    moment(rails, 'YYYY-MM-DD')

  setWeek = () ->
    weekStart = date($('#week_start').val())
    weekEnd = date($('#week_end').val())
    weekOffset = $('#week_offset').val()

  setWeek()

  crew = ($target)->
    $target.data('crew')

  $calendar.on('click', '.open-new-modal', (event) ->
    $target = $(event.currentTarget)
    start = $target.data('date')
    $modal.openNew crew($target), start
  )

  $calendar.on('click', '.open-new-blank-modal', (event) ->
    $modal.openNewBlank()
  )

  $calendar.on('click', '.open-edit-modal', (event) ->
    $target = $(event.currentTarget)
    entry = $target.data('entry')
    $modal.openEdit entry, crew($target)
  )

  if $('#crew-calendar-ibox').length
    $(document).on('click', '#unschedule-job-btn', (event) ->
      this._$modal = $modal
      $modal.deleteEvent event
    )