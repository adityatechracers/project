$ ->
  return unless $('.organization_proposal_style').length

  ## Hide/show the proposal banner text field (show if "simple" syle chosen)

  setProposalBannerText = ->
    $style = $('#organization_proposal_style')
    $bannerText = $('.organization_proposal_banner_text')

    if $style.val() == 'Simple'
      $bannerText.show()
    else
      $bannerText.hide()

  $('#organization_proposal_style').change setProposalBannerText
  setProposalBannerText()

  ## Hide/show the signature field (show if "sign automatically?" checked)

  signatureWasInitialized = false
  $signature = $('#signature')
  $signatureHiddenField= $('#organization_default_signature')

  initSignatureField = ->
    return if signatureWasInitialized

    # Initialize (using data-svg if present)
    $signature.jSignature()
    svg = $signature.data('svg')
    if svg != 'image/jsignature;base30,'
      $signature.jSignature('setData', svg, 'base30')
    signatureWasInitialized = true

  setupSignature = ->
    if $('#organization_auto_sign_proposals').is(':checked')
      $('.signature-wrapper').show()
      initSignatureField()
    else
      $('.signature-wrapper').hide()

  $('#organization_auto_sign_proposals').change setupSignature
  setupSignature()

  # When the signature changes, update the hidden field
  $signature.change ->
    data = $signature.jSignature('getData', 'base30')
    $signatureHiddenField.val(data)

  # When the clear/reset button is clicked, reset the signature box
  $('.clear-signature-btn').click ->
    $signature.jSignature('reset')
    false
