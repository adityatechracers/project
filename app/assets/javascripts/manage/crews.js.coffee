# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('#crew_has_wage_rate').change ->
    if $(this).is(':checked')
      $('.crew-wage-rate').show()
    else
      $('.crew-wage-rate').hide()
      $('#crew_wage_rate').val('')
