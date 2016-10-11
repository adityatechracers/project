$(function(){

	var email = $('#user_signup_email').html();

	if (email && email.length){
		var first_name = $('#user_signup_first_name').html();
		var last_name = $('#user_signup_last_name').html();
		var phone = $('#user_signup_phone').html();

		// TODO: Move API key to somewhere it makes sense (config)
		var url = "https://corkcrm.api-us1.com/admin/api.php?api_action=contact_add&api_key=7f51dcea825f3383b29bb524f1720bf898102bceecdf93802408c78f03f2c0f6349f1987";

		var params = {
			"api_output": "json",
			"email": email,
			"first_name": first_name,
			"last_name": last_name,
			"phone": phone,
			// TODO: Remove hardcoded list value
			"p[4]": 4
		}

		$.ajax({
		  url: url,
		  data: params,
		  method: 'POST'
		});
	}
});
