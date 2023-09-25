$(document).on('turbolinks:load', function() {
	function scrollToTop () {
		$("html, body").animate({ scrollTop: 0 }, 'slow')
	}

	$('#scroll_assist').click(function () {
		scrollToTop()
	})
})