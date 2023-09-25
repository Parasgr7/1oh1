$(document).on('turbolinks:load', function() {
    console.log('sadsad')
    var timedelay = 1;
	var _delay = setInterval(delayCheck, 500);

	$('.containerSessionVid').on('mousemove', showAllEvent);
	function delayCheck() {
	  if (timedelay == 5) {
	    $('.isHide').removeClass('showRoomBar');
	    timedelay = 1;
	  }
	  timedelay = timedelay + 1;
	}

	function showAllEvent() {
	  $('.isHide').addClass('showRoomBar');
	  timedelay = 1;
	  clearInterval(_delay);
	  _delay = setInterval(delayCheck, 500);
	}

  var stripe = Stripe('<%= Rails.configuration.stripe[:publishable_key] %>');

  var checkoutButton = document.getElementById('checkout-button-sku_G5nYYuuMxCe93q');
  checkoutButton.addEventListener('click', function () {
    // When the customer clicks on the button, redirect
    // them to Checkout.
    stripe.redirectToCheckout({
      items: [{sku: 'sku_G5nYYuuMxCe93q', quantity: 1}],

      // Do not rely on the redirect to the successUrl for fulfilling
      // purchases, customers may not always reach the success_url after
      // a successful payment.
      // Instead use one of the strategies described in
      // https://stripe.com/docs/payments/checkout/fulfillment
      successUrl: 'http://localhost:3000/payment?session_id={CHECKOUT_SESSION_ID}',
      cancelUrl: window.location.protocol + '//1oh1.org/canceled',
    })
    .then(function (result) {
      if (result.error) {
        // If `redirectToCheckout` fails due to a browser or network
        // error, display the localized error message to your customer.
        var displayError = document.getElementById('error-message');
        displayError.textContent = result.error.message;
      }
    });
  });
  
})
