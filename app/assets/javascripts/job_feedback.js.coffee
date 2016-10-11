$ ->
  return unless $('#job_feedback_customer_sig').length

  $signature = $('#signature')
  $signatureHiddenField= $('#job_feedback_customer_sig')

  # Initialize (using data-svg if present)
  $signature.jSignature()
  svg = $signature.data('svg')
  if svg != 'image/jsignature;base30,'
    $signature.jSignature('setData', svg, 'base30')

  # When the signature changes, update the hidden field
  $signature.change ->
    data = $signature.jSignature('getData', 'base30')
    $signatureHiddenField.val(data)

  # When the clear/reset button is clicked, reset the signature box
  $('.clear-signature-btn').click ->
    $signature.jSignature('reset')
    false
