# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  ### SUBNAV HOVERING
  origTab = $('.top-nav .selected')
  $('.subnav_list.active').show()

  showNav = ->
    $('.top-nav .selected').removeClass('selected')
    $('.top-nav [data-tab="'+$(this).data("tab")+'"] a').addClass('selected')
    $('.subnav_list.active').hide()
    $('#subnav_list_'+$(this).data("tab")).show()

  hideNav = (e)->
    tab = $(this)
    to = $(e.toElement || e.relatedTarget)
    if to.is(".sub-nav")
      to.mouseleave(hideNav)
    else
      $('.top-nav .selected').removeClass('selected')
      origTab.addClass('selected')
      $('.subnav_list:visible').hide()
      $('.subnav_list.active').show()

  $('.top-nav li:not(.active)').hover(showNav, hideNav)
  ###
