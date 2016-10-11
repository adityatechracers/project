$( "#organization_user_signatures" ).change(function() {
  $( "#signature_view" ).load( "/manage/organization/get_signature?user_id="+$("#organization_user_signatures").val(), function() {
    signature = $('#signature');

      signature.jSignature();
      svg = signature.data('svg');
      if (svg != 'image/jsignature;base30,' && svg != undefined) {
        signature.jSignature('setData', svg, 'base30');
      }
      bindSaveSignatureEvent();

  });
});

bindSaveSignatureEvent();

function bindSaveSignatureEvent() {
  $("#save-signature-btn").click(function(event){
    event.preventDefault();
    this.disabled = true;
    var $sigdiv = $("#signature");
    current_sig = $sigdiv.jSignature("getData","base30")[1];
    $( "#signature_view" ).load( "/manage/organization/change_signature", {user_id:$("#organization_user_signatures").val(),
     signature_value: current_sig}, function(){
      signature = $('#signature');

      signature.jSignature();
      svg = signature.data('svg');
      if (svg != 'image/jsignature;base30,' && svg != undefined) {
        signature.jSignature('setData', svg, 'base30');
      }
      bindSaveSignatureEvent();
     });
  });
  $(".clear-signature-org-tab").click(function(event){
    event.preventDefault();
    var $sigdiv = $("#signature");
    $sigdiv.jSignature("reset");
  });
}
