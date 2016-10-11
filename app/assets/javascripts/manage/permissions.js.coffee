permissionPresets =
  sales: [
    'user_can_be_assigned_appointments',
    'user_can_be_assigned_jobs',
    'user_can_view_leads',
    'user_can_manage_leads',
    'user_can_view_appointments',
    'user_can_manage_appointments',
    'user_can_view_own_jobs',
    'user_can_manage_jobs',
    'user_can_view_assigned_proposals',
    'user_can_manage_proposals',
    'user_can_make_timecards'
  ]
  painter: [
    'user_can_be_assigned_jobs',
    'user_can_view_own_jobs',
    'user_can_view_assigned_proposals',
    'user_can_make_timecards'
  ]

$ ->
  return unless (pt = $('#permission_table')).length
  pt = $('#permission_table')
  $('.permission-profile-item').click (e)->
    e.preventDefault()
    switch $(@).data('name')
      when "all-permissions"
        pt.find("input").prop("checked",true)
      when "sales"
        pt.find("input").prop("checked",false)
        $("##{preset}").prop('checked', true) for preset in permissionPresets.sales
      when "painter"
        pt.find("input").prop("checked",false)
        $("##{preset}").prop('checked', true) for preset in permissionPresets.painter
      when "no-permissions"
        pt.find("input").prop("checked",false)

  pt.find('input[type=checkbox]').change (e) ->
    if $(@).is(':checked') and $(@).data('dependency')?
      dependencies = $(@).data('dependency').split ' '
      for d in dependencies
        pt.find("#user_#{d}").prop('checked', true).trigger('change')
    else if !$(@).is(':checked')
      name = $(@).attr('id').match(/user_(.*)/)[1]
      pt.find("input[type=checkbox][data-dependency='#{name}']:checked")
        .map ->
          $(@).prop('checked', false)

  updatePermissionsState = ->
    isManager = $('#user_role').val() == 'Manager'
    pt.find('input[type=checkbox]').each ->
      unless $(this).data('original-state')?
        $(this).data('original-state', $(this).prop('checked'))
        console.log('setting original')
      originalValue = $(this).data('original-state')
      $(this)
        .prop('checked', if isManager then true else originalValue)
        .prop('disabled', isManager)
    $('.permission-profiles').toggleClass('disabled', isManager)

  $('#user_role').change updatePermissionsState
  updatePermissionsState()
