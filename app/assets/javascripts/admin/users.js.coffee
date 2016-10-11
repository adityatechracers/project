# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  return unless (osf=$('#superadmin_user_search_field')).is('*')
  getParameterByName = (name) ->
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
    results = regex.exec(location.search)
    (if results is null then null else decodeURIComponent(results[1].replace(/\+/g, " ")))
  delay = 500
  timer = null
  tbody = $('#users_table tbody')
  osf.on "input", (e)->
    tbody.html("").append($('<tr />').append($('<td />').attr('colspan',6).css({"text-align":"center","font-style":"italic","color":"#666666"}).html("Loading...")))
    clearTimeout(timer) if timer?
    timer = setTimeout ->
      params = {query: osf.val()}
      filter = getParameterByName('filter')
      page = getParameterByName('page')
      params.filter = filter if filter?
      params.page = page if page?
      tbody.load "/admin/users/table", params, -> timer = null
    , delay

  new cork.Export(source: '#export-users', location:'/admin/users/export').init()   