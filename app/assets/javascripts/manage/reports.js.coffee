# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  return unless $('#contact-distribution-map').is('*')
  contact_coordinates = $('#contact-distribution-map').data('contact-coordinates')
  map = null
  heatmap = null
  $(document).ready ->
    initialize = ->
      mapOptions =
        center: new google.maps.LatLng(-34.397, 150.644)
        zoom: 8
        mapTypeId: google.maps.MapTypeId.HYBRID
      map = new google.maps.Map(document.getElementById('contact-distribution-map'), mapOptions)
      bounds = new google.maps.LatLngBounds()
      coordinateMap = contact_coordinates.map (c)->
        latlng = new google.maps.LatLng(c.lat, c.lon)
        bounds.extend latlng
        marker = new google.maps.Marker
          position: latlng
          map: map
          title: c.name
        contentString = "<p><strong>#{c.name}</strong><br>#{c.address}</p>"
        infowindow = new google.maps.InfoWindow({ content: contentString })
        google.maps.event.addListener marker, 'click', ->
          infowindow.open map, marker
        latlng
      pointArray = new google.maps.MVCArray coordinateMap
      heatmap = new google.maps.visualization.HeatmapLayer
        data: pointArray
      heatmap.setMap map
      map.fitBounds(bounds)
    google.maps.event.addDomListener(window, 'load', initialize)

$ ->
  return unless $('#report-timesheets-widget').is('*')
  $('.timecard-status-btn').click (e)->
    statuses = []
    $('.timecard-status-btn').each -> statuses.push($(@).attr('data-status')) if $(@).hasClass('active')
    if $(@).hasClass('active')
      statuses.splice $.inArray($(@).attr('data-status'), statuses), 1
    else
      statuses.push $(@).attr('data-status')
    window.location = $.param.querystring window.location.href, "status=#{statuses.join('+')}"

$ ->
  ###
  Adds 0 left margin to the first thumbnail on each row that don't get it via CSS rules.
  Recall the function when the floating of the elements changed.
  ###
  return unless $('.report-list-widget').is('*')
  fixThumbnailMargins = ->
    $(".row-fluid .thumbnails").each ->
      $thumbnails = $(@).children()
      previousOffsetLeft = $thumbnails.first().offset().left
      $thumbnails.removeClass "first-in-row"
      $thumbnails.removeClass "most-recently-adjusted-thumbnail"
      $thumbnails.first().addClass "first-in-row"
      mostRecent = false
      $thumbnails.each ->
        $thumbnail = $(@)
        offsetLeft = $thumbnail.offset().left
        mostRecent = $thumbnail.addClass "first-in-row" if offsetLeft < previousOffsetLeft
        previousOffsetLeft = offsetLeft
      mostRecent.addClass("most-recently-adjusted-thumbnail")
      startingWith = $.inArray document.getElementsByClassName("most-recently-adjusted-thumbnail")[0], $thumbnails
      $thumbnails.each (index)-> $(@).css("margin-bottom",0) if index >= startingWith
      $(@).transition({opacity:1})

  # Fix the margins when potentally the floating changed
  $(window).load -> fixThumbnailMargins()
  # $(window).resize $.debounce(250, true, -> $('.thumbnails').css('opacity',0))
  $(window).resize $.debounce(250, fixThumbnailMargins)

  $('.report-list-widget .thumbnails li').each -> $(@).find('h4').attr("title",$(@).find('h4').html())

$ ->
  return unless $('#profit-report').is('*')

  $('.amount-format-toggle').click ->
    return if $(this).hasClass('active')
    console.log('hello')
    $('#report_details td[data-alt-value]').each ->
      [newValue, oldValue] = [$(this).data('alt-value'), $(this).text()]
      $(this)
        .text(newValue)
        .data('alt-value', oldValue)
        console.log("yo")

$ ->
  $('select[name=year]').change -> $(this).parents('form').submit()

  multiselectTimeout = null
  $('select.multiselect').multiselect(
    onChange: ->
      clearTimeout(multiselectTimeout) if multiselectTimeout?
      $form = $(this.$button).parents('form')
      multiselectTimeout = setTimeout((-> $form.submit()), 1000)
  )

$ ->
  $('.amount-format-toggle').click -> $('.amount-format-toggle').removeClass('active');
  $('.amount-format-toggle').click -> $('.amount-format-toggle').removeClass('focus'); 
