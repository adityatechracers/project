# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  window.bindCommunicationEvents = _.debounce(->
    modal = $('.communication-events-modal')
    if modal.length == 0
      modal = $('<div />').addClass("modal modal-wide hide fade communication-events-modal").appendTo($('.dashboard-wrapper').first())
    modal.on 'hidden', -> $(@).removeData('modal').html("")
    $('.next-contact-indicator').tooltip({placement:'right'})
    $('.start-planned-communication-link').click (e)->
      e.preventDefault()
      modal.load("/communications/#{$(@).attr('data-commid')}/start_planned_form", prepareStartForm)
    $('.start-new-communication-link').click (e)->
      e.preventDefault()
      modal.load("/communications/#{$(@).attr('data-job')}/start_new_form", prepareStartForm)
    $('.plan-future-communication-link').click (e)->
      e.preventDefault()
      modal.load("/communications/#{$(@).attr('data-job')}/plan_form", preparePlanForm)
    $('.edit-communication-link').click (e)->
      e.preventDefault()
      modal.load("/communications/#{$(@).attr("data-commid")}/modal", prepareEditForm)
  , 500)

  bindCommunicationEvents()

  prepareStartForm = ->
    modal = $('.communication-events-modal')

    $('.outcome-buttons .btn').click (e)->
      $("input[type=radio][name*='[outcome]'][value='"+$(@).attr('data-value')+"']").prop('checked',true)
    $('.next-step-buttons .btn').click (e)->
      v = $(@).attr('data-value')
      $("input[name='next_step'][value='"+v+"']").prop('checked',true)
      if v=="call_back_on"
        $("input[name='call_back_around_datetime']").hide()
        $("input[name='call_back_on_datetime']").show(400,->$(@).width($('.next-step-buttons').width()-14))
      else if v=="call_back_around"
        $("input[name='call_back_on_datetime']").hide()
        $("input[name='call_back_around_datetime']").show(400,->$(@).width($('.next-step-buttons').width()-14))
      else
        $("input[name='call_back_on_datetime'], input[name='call_back_around_datetime']").hide()
      $('input.datetime_picker').corkDatetimePicker cork.datetimePickerDefaults
    modal.find(".modal-footer .btn-success").unbind('click').click (e)->
      e.preventDefault()
      modal.find('.modal-body form').submit()
    modal.modal()

  prepareEditForm = ->
    modal = $('.communication-events-modal')
    modal.find(".modal-footer .btn-success").unbind('click').click (e)->
      e.preventDefault()
      modal.find('.modal-body form').submit()
    modal.modal()

  preparePlanForm = (job, contact)->
    modal = $('.dashboard-wrapper').find('.modal')
    modal.modal()

  $('.communication-history-count').click (e)->
    e.preventDefault()
    $(@).html("View all from job").attr("href","/communications/?job="+$(@).attr("data-job")).siblings(".communication-history-list").show()
    $(@).unbind(e)
  $('.contact-when-indicator').tooltip({placement:'left'})

class cork.views.CommunicationCalendar extends cork.views.Calendar
  events:
    'submit .modal form'           : 'saveEvent'
    'click #add-communication-btn' : 'openNewForm'

  filterCrews: (e) ->
    if $(e.currentTarget).is(':checked')
      @calendar.fullCalendar('refetchEvents')
    else
      id = $(e.currentTarget).data('id')
      @calendar.fullCalendar('removeEvents', (event) -> id == event.crewId)

  updateJobForm: (e) ->
    id = $(e.currentTarget).find('option:selected').val()
    @$('.modal').load @options.editForm(id), =>
      @setDates(@lastSelection.start, @lastSelection.end)
      @setupChosen()

  saveEvent: (e)-> super unless e?

  initialize: ->
    @openNewForm() if window.location.href.indexOf("open_modal")>-1
    super

$ ->
  if $('#communication-calendar-widget').is('*')
    new cork.views.CommunicationCalendar
      el: $('#communication-calendar-widget')
      modelName: 'Communication'
      newForm: '/communications/modal'
      editForm: (id) -> "/communications/#{id}/modal"
      calendar:
        events: '/communications.json'
