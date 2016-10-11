$(document).on("click", ".load-version", function(){
	var proposal_id = $("#proposal_id").attr('data-proposal-template-id');
	$.ajax({
		type: "GET",
		dataType : 'script',
		url: "/manage/proposal_templates/" + proposal_id + "/load_versions"
	})
})