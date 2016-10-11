$(document).ready(function(){

  params={};
  window.location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi,function(str,key,value){params[key] = value;});

  // profit report totals
  //@hassan added datatype
  var profitReportTotalsRow = $('#profit-report-totals');
  if (profitReportTotalsRow.length){
    var url = '/manage/reports/profit_totals'

    $.ajax({
      url: url,
      data: params,
      method: 'GET',
      dataType: 'text',
      success: function(row){
        profitReportTotalsRow.html(row);
      }
    });
  }

  // payment tracking
  // @hassan added datatype
  var paymentTrackingReportTotalsRow = $('#deposit-payment-tracking-totals');
  if (paymentTrackingReportTotalsRow.length){
    var url = '/manage/reports/deposit_payment_tracking_totals'

    $.ajax({
      url: url,
      data: params,
      method: 'GET',
      dataType: 'text',
      success: function(row){
        paymentTrackingReportTotalsRow.html(row);
      }
    });
  }
});
