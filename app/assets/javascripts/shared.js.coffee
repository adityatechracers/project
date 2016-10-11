window.cork ||= views: {}

href = window.location.pathname
$page_name = href.substr href.lastIndexOf('/') + 1

$.datepicker.setDefaults(
  $.extend(
    {dateFormat: 'm/d/yy'},
    $.datepicker.regional[RAILS_LOCALE]
  )
)

if $page_name == "timecards"
  cork.datetimePickerDefaults =
    dateFormat: 'm/d/yy'
    timeFormat: 'h:mm tt'
    controlType: 'select'
    stepMinute: 15
    hour: 9
    maxDate: new Date()
    hourMin: 6
    hourMax:21
    minuteMax:61
else
  cork.datetimePickerDefaults =
    dateFormat: 'm/d/yy'
    timeFormat: 'h:mm tt'
    controlType: 'select'
    stepMinute: 15
    hour: 9
    hourMin: 6
    hourMax:21
    minuteMax:61

cork.datePickerDefaults =
  dateFormat: 'm/d/yy'

if Cookies.get('cc-expiration-month') and Cookies.get('cc-expiration-year')
  exp_month = parseInt(Cookies.get('cc-expiration-month'))
  exp_year = parseInt(Cookies.get('cc-expiration-year'))
  now = new Date()
  month_now = now.getMonth() + 1
  year_now = now.getFullYear()
  if exp_year == year_now and exp_month-1 == month_now
    $('#expiring-cc').show()

$.fn.corkDatetimePicker = ->
  args = _.toArray(arguments)
  if navigator.userAgent.match(/iPhone|iPad|iPod/i)
    $(@).attr('type', 'datetime-local')
    $(@).each ->
      if args.length and args[0] == 'setDate'
        $(@).val(args[1].toISOString())
      else if $(@).data('iso')
        $(@).val($(@).data('iso'))
  else
    args[0] = $.extend(args[0], $(@).data('datetimepicker-opts')) if $(@).data('datetimepicker-opts')?
    $(@).datetimepicker.apply(@, args)

$.fn.corkDatePicker = ->
  args = _.toArray(arguments)
  if navigator.userAgent.match(/iPhone|iPad|iPod/i)
    $(@).attr('type', 'date')
    $(@).each ->
      if args.length and args[0] == 'setDate'
        $(@).val(args[1].toISOString())
      else if $(@).data('iso')
        $(@).val($(@).data('iso'))
  else
    args[0] = $.extend(args[0], $(@).data('datepicker-opts')) if $(@).data('datepicker-opts')?
    $(@).datepicker.apply(@, args)

$.fn.corkChosen = ->
  # return if navigator.userAgent.match(/iPhone|iPad|iPod/i)
  $(@).chosen.apply(@, _.toArray(arguments))

$ ->
  moment.locale(RAILS_LOCALE)

  $.fn.twitter_bootstrap_confirmbox.defaults =
    fade: false
    title: CORK_I18N.confirm,
    cancel: CORK_I18N.cancel,
    cancel_class: "btn cancel",
    proceed: CORK_I18N.ok,
    proceed_class: "btn proceed btn-primary"

  (->
    # Region population by country
    regions_loading = false
    countryfields = $("select[name*='[country]']")
    if countryfields.length
      countryfields.each ->
        cf = $(@)
        form = cf.parents("form")
        region = form.find("select[name*='[region]']")
        if region.length
          cf.change((e)->
            regions_loading = true
            region.html("").load "/get_regions/#{encodeURIComponent(cf.val())}", ->
              regions_loading = false
              region.val(region.data("value")) if region.data("value")?
          ).trigger("change")

    # Zip completion
    zipfields = $('input[name*=zip]')
    if zipfields.length
      zipfields.each ->
        zf = $(@)
        form = zf.parents("form")
        city = form.find("input[name*='[city]'][type=text]")
        region = form.find("select[name*='[region]']")
        country = form.find("select[name*='[country]']")

        zipcompletion_once = false
        zipcompletion_enabled = (city? or region? or country?) and (!city? or city.val()=="") and zf.val()==""
        return unless zipcompletion_enabled
        enable_zipcompletion = =>
          return if zipcompletion_enabled
          zipcompletion_enabled = true
          zf.attr "placeholder", "Enter zip code first to autofill location..."
          city.attr "placeholder", "Enter zip code first to autofill..."
          zf.popover "hide"
        disable_zipcompletion = =>
          return unless zipcompletion_enabled
          zipcompletion_enabled = false
          zf.attr "placeholder", "Location autofill disabled."
          city.attr "placeholder", ""
          zf.popover "show"
          $('.reenable-zipcompletion-btn').click (e)=>
            e.preventDefault()
            enable_zipcompletion()
            zf.focus()
          $('.dismiss-zipcompletion-popover-btn').click (e)=>
            e.preventDefault()
            zf.popover "hide"

        city.attr("placeholder", "Enter zip code first to autofill...").focus(disable_zipcompletion)
        zf.popover
          html: true
          trigger: "manual"
          placement: if $(window).width() <= 767 then "top" else "right"
          title: "Zipcode Autofill Disabled"
          content: "<p>All zipcode fields in CorkCRM are rigged to utilize a technique known as <strong>reverse geocoding</strong> to intelligently fill out the city, state, and country.  This feature is disabled when you manually edit the other location-centric fields in the form.</p><button class='btn btn-primary btn-block reenable-zipcompletion-btn'>Reenable Zipcode Autofill</button><button class='btn btn-block dismiss-zipcompletion-popover-btn'>Hide this Popover</button>"

        zf.attr("placeholder", "Enter zip code first to autofill location...").mask 'AAAAAA-AAA',
          onKeyPress:(cep, event, currentField, options)->
            return if event.keyCode == 16

            if (zipcompletion_enabled or zipcompletion_once) and zf.val().length >= 3
              zipcompletion_once = true
              city.val("")
              geocoder = new google.maps.Geocoder()
              geocoder.geocode { address: zf.val() }, (results, status)->
                return unless results.length
                data_city = data_region = data_country = null
                $.each results[0].address_components, (index,comp)->
                  data_city = comp.short_name if $.inArray("locality",comp.types)>-1 or $.inArray("postal_town",comp.types)>-1 or $.inArray("establishment",comp.types)>-1
                city.val(data_city) if data_city? and (zipcompletion_once or (city? and !city.val().length))
                return unless data_region? and (zipcompletion_once or (region? and !region.val().length))
                loadingCheck = setInterval ->
                  return if regions_loading
                  clearInterval(loadingCheck)
                , 100
  )()


  initPlugins = ->
    $('input.date_picker').corkDatePicker(cork.datePickerDefaults)
    $('input.datetime_picker').corkDatetimePicker(cork.datetimePickerDefaults)
    $('.chzn-select').corkChosen(allow_single_deselect: true)
    $('.chzn-select-required').corkChosen(allow_single_deselect: false)
    $('[data-toggle=tooltip]').tooltip()
    $('[data-toggle=popover]').popover()
    $('.color').colorpicker()
    $('input[name*=phone], input[name*=fax]').mask('(999) 999-9999')
    $('input#card_number').mask('9999 9999 9999 9999')
    $('input#expense_amount, input#payment_amount, input#proposal_deposit_amount, input#proposal_amount').mask('000,000,000,000,000.00', {reverse: true})

  initPlugins()

  $('.modal').on 'show', ->
    initPlugins()
    $('.switch').bootstrapSwitch()
    $('.modal-footer .btn-success').click (e)->
      e.preventDefault()
      $(@).parents('.modal').find('form').submit()

  # MISC
  $('.widget').each -> $(@).css("margin-bottom","0px") unless $(@).children(".widget-body,.widget-footer").is('*')
  $('.more-missed-communications-link').click (e)->
    e.preventDefault()
    $(@).hide(400)
    $('.more-missed-communications').show(400)
  $('.nav-notifications').click (e)->
    e.preventDefault()
    window.location = "/dashboard"

  (->
    first_subnav_link = $('.subnav_list.active').find('li:first-child a')
    $('#dashboard-subnav-btn').html(first_subnav_link.html()).attr("href",first_subnav_link.attr("href"))
    $('#dashboard-subnav-dropdown').html($.map($('.subnav_list.active li:not(:first-child)'), (me)-> "<li style='padding:5px;'>#{$(me).html()}</li>" ).join(""))
  )()

  # HEX ANIMATION
  (->
    hexAnimation = (cb)->
      _w = $(window).width()
      _h = $(window).height()
      squareSize = 128
      colGrouping = 1
      colsNeeded = Math.ceil(_w/(squareSize*colGrouping))
      rowsNeeded = Math.ceil((_h*colGrouping)/squareSize)
      squaresNeeded = colsNeeded * rowsNeeded
      flipTime = 400
      fadeTime = 100
      transitionTime = flipTime/4

      overlay = $('<div />').appendTo($('body')).css
        position:'fixed'
        top:0
        left:0
        width:"100%"
        height:"100%"
        background:"transparent"
        "z-index":1000
      for i in [0..colsNeeded-1]
        col = $('<div />').appendTo(overlay).addClass('overlay-col').css
          float:"left"
          position:"absolute"
          top:0
          left:squareSize*i*colGrouping
          background:"transparent"
          width:squareSize*colGrouping
          height:"100%"
          opacity:0
        for j in [0..rowsNeeded-1]
          $('<div />').appendTo(col).addClass('overlay-square').css
            width:squareSize-2
            height:squareSize-2
            float:"left"
            background:"rgba(0,0,0,0.3)"
            border:"1px solid rgba(0,0,0,0.1)"

      flipColumn = (i)-> ->
        col = $(".overlay-col:nth-child(#{i})")
        col.transition {opacity:1},fadeTime
        col.find(".overlay-square").transition {rotate3d:'1,1,0,180deg'},flipTime
        cb?()
      setTimeout flipColumn(i), i*transitionTime for i in [1..colsNeeded]
      # setTimeout ->
      #   overlay.transition {y:_h}, 400, "ease", ->
      #     overlay.remove()
      #     cb?()
      # , (transitionTime*colsNeeded)+flipTime

    # $('.become-btn').click (e)->
    #   e.preventDefault()
    #   href = $(@).attr('href')
    #   hexAnimation -> window.location = href
  )()

  # NAV ARROW
  (->
    o = {
      speed:400
      revertDelay:1000
      debounceDelay:500
      checkInterval:10000
      doCheck:false
    }
    arrow = $('.nav-arrow')
    arrowEnabled = firstArrowPosition = transitionInProgress = false
    revertTimer = null
    arrowPosition = (el)-> el.offset().left + (el.outerWidth()/2) - (arrow.outerWidth()/2)
    activeLink = $('.subnav_list.active li a.active')

    clearRevertTimer = ->
      if revertTimer?
        clearTimeout revertTimer
        revertTimer = null

    revertTransition = ->
      return if transitionInProgress
      transitionInProgress = true
      arrow.transition({left:firstArrowPosition,queue:false},o.speed)
      setTimeout ->
        transitionInProgress = false
        revertTimer = null
        arrow.data('href',activeLink.attr("href"))
      , o.speed

    fix_arrow = ->
      return unless activeLink.is('*')
      firstArrowPosition = arrowPosition(activeLink)
      arrow.css({left:firstArrowPosition}).data("href",activeLink.attr("href"))
      arrow.transition({marginTop:-10,opacity:1,queue:false})
      arrowEnabled = true
      $('.subnav_list.active li a:hover').trigger("mouseover") if $('.subnav_list.active li a:hover').is('*')
    $(window).load fix_arrow
    $(window).resize $.debounce(o.debounceDelay,true,-> arrow.transition({marginTop:0,opacity:0,queue:false},o.speed/2))
    $(window).resize $.debounce(o.debounceDelay,fix_arrow)

    # Arrow checker
    if o.doCheck
      setInterval ->
        return unless arrowEnabled and !transitionInProgress and !revertTimer?
        revertTransition() if arrow.data("href") != activeLink.attr("href")
      , o.checkInterval

    arrow.click (e)->
      e.preventDefault()
      window.location = $(@).data("href")

    $('.subnav_list.active li a').hover (e)->
      link = $(@)
      arrow.dequeue() if transitionInProgress
      transitionInProgress = true
      clearRevertTimer()
      arrow.transition({left:arrowPosition(link),queue:false},o.speed)
      setTimeout ->
        transitionInProgress = false
        arrow.data('href',link.attr("href"))
      , o.speed
    , (e)->
      clearRevertTimer()
      revertTimer = setTimeout revertTransition, o.revertDelay
  )()

#  We can attach the `fileselect` event to all file inputs on the page

$ ->
  # We can attach the `fileselect` event to all file inputs on the page
  $(document).on 'change', ':file', ->
    input = $(this)
    numFiles = if input.get(0).files then input.get(0).files.length else 1
    label = input.val().replace(/\\/g, '/').replace(/.*\//, '')
    input.trigger 'fileselect', [
      numFiles
      label
    ]
    return
  # We can watch for our custom `fileselect` event like this
  $(document).ready ->
    $(':file').on 'fileselect', (event, numFiles, label) ->
      input = $(this).parents('.input-group').find(':text')
      log = if numFiles > 1 then numFiles + ' files selected' else label
      if input.length
        input.val log
      else
        if log
          alert log
      return
    return
  return

( ($) ->
  $.widget 'ui.onDelayedKeyup',
    _init: ->
      self = this
      $(@element).keyup ->
        if typeof window['inputTimeout'] != 'undefined'
          window.clearTimeout inputTimeout
        handler = self.options.handler
        window['inputTimeout'] = window.setTimeout((->
          handler.call self.element
          return
        ), self.options.delay)
        return
      return
    options:
      handler: $.noop()
      delay: 500
  return
) jQuery

$ ->
  $('.summernote').summernote({
     minHeight: 100,
    toolbar: [
      ['style', ['style']],
      ['font', ['bold', 'italic', 'underline', 'clear']],
      ['fontname', ['fontname']],
      ['color', ['color']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['table', ['table']],
      ['insert', ['link', 'picture', 'hr']],
      ['view', ['codeview']],
      ['help', ['help']]
    ]
  });

  $('.summernote-md').summernote({
     minHeight: 300,
    toolbar: [
      ['style', ['style']],
      ['font', ['bold', 'italic', 'underline', 'clear']],
      ['fontname', ['fontname']],
      ['color', ['color']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['table', ['table']],
      ['insert', ['link', 'picture', 'hr']],
      ['view', ['codeview']],
      ['help', ['help']]
    ]
  });

  $('.summernote-lg').summernote({
     minHeight: 450,
    toolbar: [
      ['style', ['style']],
      ['font', ['bold', 'italic', 'underline', 'clear']],
      ['fontname', ['fontname']],
      ['color', ['color']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['table', ['table']],
      ['insert', ['link', 'picture', 'hr']],
      ['view', ['codeview']],
      ['help', ['help']]
    ]
  });

$ -> $('input[type=text].minicolors').minicolors theme: 'bootstrap'


$(document).ready ->
  setTimeout (->
    $('.alert-warning.flash-alert, .alert-info.flash-alert, .alert-success.flash-alert').fadeOut 'slow'
    return
  ), 5000
  return