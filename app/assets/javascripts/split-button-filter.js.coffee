$ ->
  $.fn.extend
    splitButtonFilter: (options) ->
      settings = $.extend {}, options
      return @each ()->
        origtext = $(@).data('origtext')
        mainbtn = $(@).find('.sbf-main-btn').click (e)-> $(@).html(origtext).removeClass('active')
        links = $(@).find('li a').click (e)-> mainbtn.html($(@).html()+"<i class='icon-close' style='position:relative;top:-1px;right:-3px;'></i>").addClass('active').data("value",$(@).data("value"))
  $('.split-button-filter').splitButtonFilter({})
