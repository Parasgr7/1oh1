$(document).on('turbolinks:load', function() {

	$('.subtitle').click(function(event){
        let selected = event.target;
    });
    
	$(function () {	
		$(".rateYoCustom").each(function(){
		if ( $(this).attr("rating") != null || $(this).attr("rating") != undefined || $(this).attr("rating") != "" ) {
			if ($(this).attr("starsSize") == "normal") {
				$(this).rateYo({
					rating: $(this).attr("rating"),
					ratedFill: "#f1c40f",
					normalFill: "#e4e4e4",
					readOnly: true,
					starWidth: "30px"
				});
			}
			if ($(this).attr("starsSize") == "small") {
				$(this).rateYo({
					rating: $(this).attr("rating"),
					ratedFill: "#f1c40f",
					normalFill: "#e4e4e4",
					readOnly: true,
					starWidth: "20px"
				});	
			}
		}			
		});

		var $rateYo = $(".rateYoInput").rateYo({
			rating: 3,
			ratedFill: "#f1c40f",
		normalFill: "#e4e4e4",
		onSet: function (){
			var rating = $rateYo.rateYo("rating");
			window.alert("Its " + rating + " Yo!");
		}
		}); 	
	});
})