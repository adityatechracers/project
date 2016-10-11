$ ->
  return unless $('#website-embed').length

  $embed = $('#website-embed')
  $leadBox = $('input#include-lead-form')
  $apptBox = $('input#include-appointment-form')

  verifyOptions = (e) ->
    return true if $apptBox.is(':checked') or $leadBox.is(':checked')
    $(e.currentTarget).prop 'checked', true
    alert 'Please select at least one embed option'

  updatePreview = ->
    $('iframe').attr 'src', $embed.text().match(/src='([^\s]*)'/)[1]

  $leadBox.change (e) ->
    return unless verifyOptions(e)
    value = if $(@).is(':checked') then 1 else 0
    $embed.html($embed.html().replace /lead_form=\d/, "lead_form=#{value}")
    updatePreview()

  $apptBox.change (e) ->
    return unless verifyOptions(e)
    value = if $(@).is(':checked') then 1 else 0
    $embed.html($embed.html().replace /appointment_form=\d/, "appointment_form=#{value}")
    updatePreview()
