# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  # LEADS IMPORT
  $('#leads_file_form input').change (e)->
    $(@).parents("form").ajaxSubmit
      beforeSubmit: (a,f,o)->
        o.dataType = "json"
        $('.import-form-ibox, .alert-error').remove()
      complete: (XMLHttpRequest, textStatus)->
        $('.row-fluid').append(XMLHttpRequest.responseText).children('.import-form-ibox').show 400, ->
          $('#lead_import_matching_form').submit (e)->
            e.preventDefault()
            $('.import-form-ibox').hide(400)
            $.ajax "/leads/import",
            type: 'POST'
            data: $(@).serialize()
            dataType: 'text'
            error: (data) ->
              alertify.error(data)
            success: (data) ->
              alertify.success(data)


  # NEW LEADS
  if $('#new_lead').is("*")
    usingExistingContact = false
    tabSwitcher = ->
      switch $('#new-contact-tabs li.active').attr('id')
        when "contact-details"
          $('#existing-contact-form-well').hide().find("select")
            .prop("disabled",true)
            .trigger('liszt:updated')
          $('#new-contact-form-well').show().find("input").prop("disabled",false)
          $('#plan-next-comm-wrapper').removeClass('pull-left').addClass('pull-right')
          usingExistingContact = false
        when "use-existing-contact"
          $('#new-contact-form-well').hide().find("input").prop("disabled",true)
          $('#contact_which_chzn')
          $('#existing-contact-form-well').show().find("select")
            .prop("disabled",false)
            .trigger('liszt:updated')
          $('#plan-next-comm-wrapper').removeClass('pull-right').addClass('pull-left')
          usingExistingContact = true
    tabSwitcher()

    $('#new-contact-tabs a').click (e)->
      e.preventDefault()
      $(@).tab("show")
      tabSwitcher()

    $('#plan-next-comm-switch').change (e)->
      if $(@).prop('checked')
        $('.plan-next-comm-form').show 400, -> $(@).find('input, select').prop('disabled',false)
      else
        $('.plan-next-comm-form').hide 400, -> $(@).find('input, select').prop('disabled',true)
    .trigger('change')

    defaultNextCommunication = moment().add('d', 1).toDate() # .format('M/D/YYYY h:mm a')
    $('#contact_jobs_attributes_0_communications_attributes_0_datetime').datetimepicker('setDate', (new Date()))

    $('#new_contact').submit (e)->
      return true if usingExistingContact
      $('.control-group').removeClass("error")
      errors = []
      $('input.required').each ->
        if $(@).val()==""
          $(@).parents(".control-group").addClass("error")
          errors.push($(@))
      return true if errors.length == 0
      alertify.error "Please fill out all required fields and try again!"
      false

  if (csf=$('#leads_search_field')).is('*')
    delay = 500
    timer = null
    tbody = $('#leads_table tbody')
    csf.on "input", (e)->
      tbody.html("").append($('<tr />').append($('<td />').attr('colspan',6).css({"text-align":"center","font-style":"italic","color":"#666666"}).html("Loading...")))
      clearTimeout(timer) if timer?
      timer = setTimeout (-> loadSearchResults()), delay

  loadSearchResults = ->
    tbody.load("/leads/table"+window.location.search, {query:csf.val()}, ->
      timer = null
      bindCommunicationEvents()
    )

  $(document).on "click", "td.footable", ->
    $caret = $(@).parent().find("span[class^='caret-']").first()
    $caret.toggleClass("caret-right caret-down");
    $detail_row = $(@).parent().next('tr.footable-row-detail')
    $detail_row.slideToggle(100)
