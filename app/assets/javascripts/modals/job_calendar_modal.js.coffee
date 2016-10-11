DateHelper = 
  newDate: (str) =>
    moment(new Date(str))

class JobCalendarModal 

  @newForm: '/job_schedule_entries/modal'
  
  @editForm: (id) -> "/job_schedule_entries/#{id}/modal"

  @calendar: cork.views.Calendar 
  
  @entryName: 'Entry'

  constructor: (@el, @options) ->
    @el.on('show', =>
      @setupCallbacks()
    )  

  setupCallbacks: =>  
    @el.find('form').submit @saveEvent  
    @el.find('#unschedule-job-btn').click @deleteEvent

  modal: (option, callback=null) =>
    @el.modal option
    callback() if callback 

  setCrew: (@crew) =>
    cork.ChosenSelect.update @el.find('#job_schedule_entry_crew_id'), @crew
  
  setDates: (start, end) ->
    @constructor.calendar.setDates(@el, start, end)
  
  startDate: =>
    DateHelper.newDate @el.find('input.start_datetime').val()
  
  endDate: => 
    DateHelper.newDate @el.find('input.end_datetime').val()
    
  updateState: =>
    @startDate = DateHelper.newDate(@el.find('#job_schedule_entry_start_datetime').val())
    @crew =  @el.find('#job_schedule_entry_crew_id').val()
  
  afterSave: (event) =>
    @updateState()
    done = => 
      @constructor.calendar.afterSave @modal
    if @options.afterSave
      @options.afterSave @crew, @startDate, done, @updateError 
    else
      done() 

  onFailedSave: (res) =>
    @constructor.calendar.onFailedSave res, @el

  afterDelete: (event) =>
    @updateState()
    done = => 
      @constructor.calendar.afterDelete @modal
    if @options.afterDelete
      @options.afterDelete @crew, @startDate, done, @updateError 
    else
      done() 

  updateError: (e) => 
    @onFailedSave(e)  

  saveEvent: (event) => 
    success = (e) => 
      @afterSave(e)
    @constructor.calendar.saveEvent event, success, @updateError, el:@el
 
  deleteEvent: (event) => 
    success = (e) => 
      @afterDelete(e)
    @constructor.calendar.deleteEvent event, success, {el:@el, name:@constructor.entryName}, @updateError
    

  openEdit: (entry, @crew) -> 
    @el.load @constructor.editForm(entry), => 
      @modal "show"
      @setDates @startDate(), @endDate()

  openNewBlank: -> 
    @el.load @constructor.newForm, => 
      today = moment()
      @modal "show" 
      @setDates today, today   

  openNew: (crew, start) ->
    @el.load @constructor.newForm, => 
      startDate = moment(start)
      endDate = moment(start)
      endDate.add(17,'hours')
      @modal "show", => 
        @setCrew crew
        @setDates startDate, endDate

cork.JobCalendarModal = JobCalendarModal