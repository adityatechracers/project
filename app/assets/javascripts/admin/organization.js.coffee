# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  Date.prototype.stdTimezoneOffset = ->
    jan = new Date(this.getFullYear(), 0, 1)
    jul = new Date(this.getFullYear(), 6, 1)
    return Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset())
  Date.prototype.dst = -> return this.getTimezoneOffset() < this.stdTimezoneOffset()

  # EDIT FORM
  offset = new Date().getTimezoneOffset() / 60 * -1
  tz_select = $('#organization_time_zone')
  options = tz_select.find('option')

  
#  tz_select.find('option').each ->
#    if (html = $(@).html()).indexOf("GMT")>-1
#      option_offset = parseInt(html.split("GMT")[1].split(":")[0]) + (new Date().dst() ? 1 : 0)
#      if option_offset == offset
#        tz_select.val($(@).val())
#        return false
#    else return false

  tlp_group = $('#org_timecard_lock_period_btngroup')
  tlp_group.find('.btn').click (e)-> $('#organization_timecard_lock_period').val($(@).html())
  tlp_group.find('.btn[data-value="'+tlp_group.data('value')+'"]').click().addClass('active')

jQuery ->
  return unless (osf=$('#superadmin_org_search_field')).is('*')
  getParameterByName = (name) ->
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
    results = regex.exec(location.search)
    (if results is null then null else decodeURIComponent(results[1].replace(/\+/g, " ")))
  delay = 500
  timer = null
  tbody = $('#organizations_table tbody')
  osf.on "input", (e)->
    tbody.html("").append($('<tr />').append($('<td />').attr('colspan',6).css({"text-align":"center","font-style":"italic","color":"#666666"}).html("Loading...")))
    clearTimeout(timer) if timer?
    timer = setTimeout ->
      params = {query: osf.val()}
      filter = getParameterByName('filter')
      page = getParameterByName('page')
      params.filter = filter if filter?
      params.page = page if page?
      tbody.load "/admin/organizations/table", params, -> timer = null
    , delay
