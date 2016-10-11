//= require ./lead
var flag=true;
$(document).ready(function(){
	$(document).bind("change keyup", function(event){
   		zestimate();
	});


	$(document).on('change','#contact_discard_zestimate', function(event){
		if($(this).is(':checked')){
			event.stopImmediatePropagation();
			event.preventDefault();
			$('#contact_zestimate').val("");
			$('#zetimate_val').html('Value Discarded');
		}
		else{

		}
	});
});
function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
function zestimate(){
	if(!$('#contact_address').val())
	{
		$('#zetimate_val').html('Please enter address');
	}
	else if(!$('#contact_zip').val())
	{
		$('#zetimate_val').html('Please enter zipcode');
	}
	else if(!$('#contact_city').val())
	{
		$('#zetimate_val').html('Please enter city');
		console.log($('#contact_city').val());
	}
	else if(!$('#contact_country').val())
	{
		$('#zetimate_val').html('Please enter country');
	}
	else{
		if(flag)
		{
			flag = false;
			$('#zetimate_val').html('Loading ...');
			$.ajax({
				url: '../../contacts/zestimate',
				data: {'address':$('#contact_address').val(), 'zip':$('#contact_zip').val(), 'city':$('#contact_city').val(), 'state':$('#contact_region').val(), 'country':$('#contact_country').val() },
				method: 'GET',
				dataType: 'text',
				success: function(row){
				if($('#contact_discard_zestimate').is(':checked')){
					$('#zetimate_val').html("Value Discarded");
					$('#contact_zestimate').val("");
				}
				else
				{
					$('#zetimate_val').html(numberWithCommas(row)+ ' USD');
					integer = row.replace(/,/g, "");
					if(Math.floor(integer) == integer && $.isNumeric(integer)){
						$('#contact_zestimate').val(row);
					}
					else{
						$('#contact_zestimate').val("");
					}
				}
					

					flag=true;
				},
				error: function(){
					flag=true;
				}
			});
		}
	}
}