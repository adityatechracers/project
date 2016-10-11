window.StripePayments = do ->

  setupForm = ->
    $('.subscription-button').click (e) ->
      e.preventDefault()
      if parseInt($(@).attr('data-active-users')) <= parseInt($(@).attr('data-plan-users'))
        $('a.btn-block.active').removeClass 'active'
        $(@).addClass 'active'
        $('#upgrade-heading').html $(@).html()
        $("#organization_stripe_plan_id_#{$(@).attr('data-plan')}").prop('checked', true)
        $('#inquiry_form_wrapper').hide()
        $('#subscription_form_wrapper').show()
        $('html, body').animate({ scrollTop: $(document).height() }, "slow");
      else
        $('#inquiry_form_wrapper').hide()
        $('#subscription_form_wrapper').hide()
        $('#invalid_subscription').show();  

    $('.contact-us-button').click (e) ->
      e.preventDefault()
      $('a.btn-block.active').removeClass 'active'
      $(@).addClass 'active'
      $('#subscription_form_wrapper').hide()
      $('#inquiry_form_wrapper').show()
      $('html, body').animate({ scrollTop: $(document).height() }, "slow");

    $('#subscription_form_wrapper form').submit (e) ->
      e.preventDefault()
      if $('#card_number').length and $("#card_number").val().length > 0 and $('form input[type=radio]:checked').length > 0
        $('input[type=submit]').attr('disabled', true)
        processCard()
      else
        alert('Your form is incomplete, check your credit card information and make sure you have selected a plan.')

  processCard = ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Cookies.set('cc-expiration-month', card['expMonth'], { expires: 1} )
    Cookies.set('cc-expiration-year', card['expYear'], { expires: 1} )
    Stripe.createToken(card, handleStripeResponse)

  handleStripeResponse = (status, response) ->
    if status == 200
      $('#organization_stripe_card_token').val(response.id)
      $('#subscription_form_wrapper form')[0].submit()
    else
      $('#stripe-error').text(response.error.message).show()
      $('input[type=submit]').attr('disabled', false)

  init: ->
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
    $('#stripe-error').hide()

    $(".edit-credit-card").click ->
      $(".credit-card-details").removeClass("hide")
      $(@).hide()
    setupForm()


window.StripeCards = do ->

  setupForm = ->
    $('#card_form_wrapper form').submit (e) ->
      e.preventDefault()
      if $('#card_number').length and $("#card_number").val().length > 0
        $('input[type=submit]').attr('disabled', true)
        processCard()
      else
        alert('Your form is incomplete, check your credit card information.')

  processCard = ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Cookies.set('cc-expiration-month', card['expMonth'], { expires: 1} )
    Cookies.set('cc-expiration-year', card['expYear'], { expires: 1} )
    Stripe.createToken(card, handleStripeResponse)

  handleStripeResponse = (status, response) ->
    if status == 200
      $('#organization_stripe_card_token').val(response.id)
      $('#card_form_wrapper form')[0].submit()
    else
      $('#stripe-error').text(response.error.message).show()
      $('input[type=submit]').attr('disabled', false)

  init: ->
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
    $('#stripe-error').hide()
    setupForm()
