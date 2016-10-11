$ ->
  # CONTRACT SIGNATURE FORMS
  $('.signature').each ->
    $(@).jSignature().change (e)-> $(@).parent().find('.signature-svg').val($(@).jSignature("getData","base30"))
    $(@).jSignature("setData",$(@).data("svg"),"base30") unless $(@).data("svg") == ""
  $('.clear-sig-button').click (e)->
    e.preventDefault()
    $(@).siblings('.signature').jSignature("clear")
    $(@).parent().find('.signature-svg').val("")
  $('.signature-readonly').each ->
    $(@).jSignature({readOnly:true})
    $(@).jSignature("setData",$(@).data("svg"),"base30") unless $(@).data("svg") == ""

  $signature_form = $('.contract-signature-form')

  $(document).on 'ajax:complete', $signature_form , (_, response) ->
    $signature_form.spin(false)

  $signature_form.submit (e)->
    errors = []
    empty = 0
    $('.signature').each ->
      $(@).css("border-color","#CCCCCC")
      printed_name = $(@).parent().find(".sig-printed-name-field").val().length
      strokes = $(@).jSignature("getData", "native").length
      if !printed_name and !strokes
        empty += 1
      else if !printed_name and strokes
        $(@).parent().find(".sig-printed-name-field").parents(".control-group").addClass("error")
        errors.push("Please print your name to continue.")
      else if printed_name and !strokes
        $(@).css("border-color","#B94A48")
        errors.push("Please draw your signature to continue.")
    errors.push("You must sign at least one name to continue.") if empty==2
    if errors.length
      $.each errors, (index,error)-> alertify.error(error)
      return false

    $signature_form.spin()

  # NEW PROPOSAL FORM
  if $('form.new_proposal, form.edit_proposal').is('*')
    job_select = $('#proposal_job_id').change (e)->
      $.post "/jobs/fetch", {id: $(@).val()}, (job)->
        $('#proposal_region').load "/get_regions/#{encodeURIComponent(job.contact.country)}", ->
          $('#proposal_address').val(job.contact.address)
          $('#proposal_address2').val(job.contact.address2)
          $('#proposal_city').val(job.contact.city)
          $('#proposal_region').val(job.contact.region)
          $('#proposal_country').val(job.contact.country)
          $('#proposal_zip').val(job.contact.zip)
    $('#new_proposal #proposal_job_id').trigger("change") if job_select.is('*') and job_select.val().length
    $('th.include_exclude_cell').click (e)-> $(@).parents("table").find("td:nth-child(#{$(@).index()+1})").click()
    $('td.include_exclude_cell').click (e)-> $(@).find("input").prop("checked",true)

  # Search Proposals
  if (csf=$('#proposal_search_field')).is('*')
    delay = 500
    timer = null
    tbody = $('#proposals_table tbody')
    csf.on "input", (e)->
      tbody.html("").append($('<tr />').append($('<td />').attr('colspan',9).css({"text-align":"center","font-style":"italic","color":"#666666"}).html("Loading...")))
      clearTimeout(timer) if timer?
      timer = setTimeout (-> loadSearchResults()), delay

  loadSearchResults = ->
    tbody.load("/proposals/table"+window.location.search, {query:csf.val()}, ->
      timer = null
      bindCommunicationEvents()
    )


angular.module('change-order', []).controller 'AppCtrl', ['$scope', '$element', ($scope, $element) ->
  $scope.proposal = $element.data('proposal')
]


# PROPOSAL HEADER PREVIEW

# Intended behavior:

# On new selection ->
#   - get new lead selected
#   - submit request for lead contact
#   - generate preview header with contact and contractor info (use code from views/proposals/_header_table)

$(window).load ->
  setTitle = ->
    proposalTitle = $('#proposal_title')
    proposalNumber = $('#proposal_proposal_number').val()
    selectedName = $('.set-header-preview').siblings('.chzn-container-single').find('.chzn-single span').html().split('-')[0].trim()
    proposalTitle.val(selectedName + " - #" + proposalNumber)
    console.log(selectedName + " | " + proposalNumber + " | " + proposalTitle)
    getHeaderPreview()

  getHeaderPreview = ->
    formData = $('.set-header-preview').closest('form').serialize()
    $.ajax '/header_table_preview',
      type: 'POST'
      dataType: 'text',
      data: formData,
      error: (jqXHR, textStatus, error) ->
        if error
          $('.proposal-header-preview').html(error)
      success: (res, textStatus, jqXHR) ->
        $('.proposal-header-preview').html(res)


  $('.set-header-preview').chosen().change( ->
    selectIndex = $(this).val()
    if selectIndex
      $('.form-generated').show()
      href = window.location.pathname
      $page_name = href.substr href.lastIndexOf('/') + 1
      if $page_name == 'new'
        setTitle()
    else
      $('.form-generated').hide()
      $('.proposal-header-preview').html('<div class="ibox none-selected"><div class="ibox-title"><h4>Select lead for proposal header preview</h4></div></div>')
  )

  $('.set-header-preview').change()

  $('#proposal_proposal_number').onDelayedKeyup({
    handler: -> (
      if ($.trim($(this).val()).length > 0)
        setTitle()
    )
  })
  $('#proposal_title').onDelayedKeyup({
    handler: -> (
      if ($.trim($(this).val()).length > 0)
        getHeaderPreview()
    )
  })

  $('#proposal_sales_person_id').change ->
    getHeaderPreview()
    return

  $('#proposal_proposal_date').change ->
    getHeaderPreview()
    return
  

$('#change-order-modal').on 'shown.bs.modal', ->
  $('#empty_description_error').html("")

$ ->
  $('#n_change_order').click ->
    if $('#change_order_change_description').val() != ""
      $('#new_change_order').submit()
    else
      $('#empty_description_error').html("<div style='color:red; margin-left:10px;'><i>Change description can not be blank.</i></div><br />")

  $('#proposal_upload_file').click -> $('#new_proposal_file').submit()

$ ->
  $(document).on "change", "#proposal_job_id", ->
    contact = $('#proposal_job_id option:selected').val()+"_hidden_contact"
    contact = $('#'+contact).data('contact')
    if(contact)
      $('.customer_rating').fadeIn()
      $('#contact_rating_contact_id').val(contact)
      $('#contact_rating_rating_id').val("1")
    else
      $('.customer_rating').fadeOut()
      $('#contact_rating_contact_id').val('')
      $('#contact_rating_rating_id').val('')

$ ->
  $('#proposal_job_id').val($('#proposal_job_id option:selected').val()).change()
  contact = $('#proposal_job_id option:selected').val()+"_hidden_contact"
  contact = $('#'+contact).data('contact')
  if(contact)
    $('#contact_rating_contact_id').val(contact)
    $.ajax 'get_contact_rating',
      type: 'GET'
      dataType: 'text',
      data: {'contact':contact, 'stage':'Proposal'},
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('something went wrong')
      success: (data, textStatus, jqXHR) ->
        $('#contact_rating_contact_id').val(contact)
        $('#contact_rating_rating_id').val(data)

$ ->
  $(document).on "click", "#a_h_address_f", ->
    $('#hidden_a_f').fadeIn()
    $('#proposal_proposal_address').val($('#original_address').html())