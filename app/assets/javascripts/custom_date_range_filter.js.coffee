return unless $('#custom_date_range_filter').length

$customDateRangeFilter = $('#custom_date_range_filter')

labels =
  fr_CA:
    TODAY        : "Aujourd'hui"
    YESTERDAY    : "Hier"
    LAST_7_DAYS  : "Les 7 derniers jours"
    LAST_30_DAYS : "Les 30 derniers jours"
    THIS_MONTH   : "Ce mois-ci"
    LAST_MONTH   : "Le mois dernier"
    CUSTOM_RANGE : "Éventail personnalisé"
    APPLY        : "Soumettre"
    CANCEL       : "Annuler"
    FROM         : "De"
    TO           : "À"

  en:
    TODAY        : 'Today'
    YESTERDAY    : 'Yesterday'
    LAST_7_DAYS  : 'Last 7 Days'
    LAST_30_DAYS : 'Last 30 Days'
    THIS_MONTH   : 'This Month'
    LAST_MONTH   : 'Last Month'
    CUSTOM_RANGE : 'Custom Range'
    APPLY        : 'Apply'
    CANCEL       : 'Cancel'
    FROM         : 'From'
    TO           : 'To'

locale = RAILS_LOCALE.replace('-', '_')
moment.locale(RAILS_LOCALE)

currentValue = $('#cdr_value').text().replace(/^\s+|\s+$/g, '')
defaultValue = $('#cdr_value').data('default')
# Compare the default (i.e., "Filter by Date" or a translation) to the current selection.
filterIsSet = currentValue != defaultValue

options =
  locale:
    applyLabel       : labels[locale].APPLY
    cancelLabel      : labels[locale].CANCEL
    fromLabel        : labels[locale].FROM
    toLabel          : labels[locale].TO
    customRangeLabel : labels[locale].CUSTOM_RANGE

if filterIsSet
  options.startDate = currentValue.split(" - ")[0]
  options.endDate   = currentValue.split(" - ")[1]

options.ranges = {}
options.ranges[labels[locale].TODAY]        = [new Date(), new Date()]
options.ranges[labels[locale].YESTERDAY]    = [moment().subtract(1, 'days'), moment().subtract(1, 'days')]
options.ranges[labels[locale].LAST_7_DAYS]  = [moment().subtract(6, 'days'), new Date()]
options.ranges[labels[locale].LAST_30_DAYS] = [moment().subtract(29, 'days'), new Date()]
options.ranges[labels[locale].THIS_MONTH]   = [moment().startOf('month'), moment().endOf('month')]
options.ranges[labels[locale].LAST_MONTH]   = [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]

removeLocationParam = (key)->
  l = window.location.href
  l = l.split("#")[0] if l.indexOf("#")>-1
  if l.indexOf(key)>-1
    params = l.split("?")[1].split("&")
    $.each params, (index,param)-> params.splice(index, 1) if param? and param.match(///^#{key}=///)
    l = l.split("?")[0]
    l += "?" + params.join("&") if params.length>0
  return l

$customDateRangeFilter.daterangepicker options, (start, end) ->
  l = removeLocationParam("custom_date_range")
  if start? and end?
    end = end.endOf('day')
    $('#cdr_value').html("#{start.format('L')} - #{end.format('L')}").parent().addClass('active')
    l += if l.indexOf("?")>-1 then "&" else "?"
    l += "custom_date_range=#{start},#{end}"
  else
    $('#cdr_value').html("Filter by date...").parent().removeClass('active')
  window.location = l

$('#cdr-calendar-btn').click (e)->
  e.preventDefault()
  if $(@).hasClass('active')
    $(@).removeClass('active')
    $('#cdr_value').html("Filter by date...")
    window.location = removeLocationParam("custom_date_range")
  else
    $customDateRangeFilter.click()
