$(document).on('turbolinks:load', function() {
    AOS.init({
        duration: 800,
        easing: 'slide',
        once: true
    });
    var starConfig = {
      starWidth: '20px',
      ratedFill: '#ffb649',
      rating: 3.5,
      readOnly: true
    };
    // Your web app's Firebase configuration
    const firebaseConfig = {
        apiKey: "AIzaSyCrwMYEa32U63xD3JeLsL8eQ5AiLTav37Q",
        authDomain: "oh1-b365f.firebaseapp.com",
        databaseURL: "https://oh1-b365f.firebaseio.com",
        projectId: "oh1-b365f",
        storageBucket: "oh1-b365f.appspot.com",
        messagingSenderId: "340774294942",
        appId: "1:340774294942:web:cab3d13c23c64897"
    };
    if (!firebase.apps.length) {
      firebase.initializeApp(firebaseConfig);
    }

    // Initialize Firebase
    // firebase.initializeApp(firebaseConfig);

      "use strict";
      $('.rateYo').rateYo(starConfig);

      var siteMenuClone = function() {
          setTimeout(function() {

              var counter = 0;
              $('.site-mobile-menu .has-children').each(function(){
                  var $this = $(this);

                  $this.prepend('<span class="arrow-collapse collapsed">');

                  $this.find('.arrow-collapse').attr({
                      'data-toggle' : 'collapse',
                      'data-target' : '#collapseItem' + counter,
                  });

                  $this.find('> ul').attr({
                      'class' : 'collapse',
                      'id' : 'collapseItem' + counter,
                  });

                  counter++;

              });

          }, 1000);

          $('body').on('click', '.arrow-collapse', function(e) {
              var $this = $(this);
              if ( $this.closest('li').find('.collapse').hasClass('show') ) {
                  $this.removeClass('active');
              } else {
                  $this.addClass('active');
              }
              e.preventDefault();

          });

          $(window).resize(function() {
              var $this = $(this),
                  w = $this.width();

              if ( w > 768 ) {
                  if ( $('body').hasClass('offcanvas-menu') ) {
                      $('body').removeClass('offcanvas-menu');
                  }
              }
          })

          $('body').on('click', '.js-menu-toggle', function(e) {
              var $this = $(this);
              e.preventDefault();

              if ( $('body').hasClass('offcanvas-menu') ) {
                  $('body').removeClass('offcanvas-menu');
                  $this.removeClass('active');
              } else {
                  $('body').addClass('offcanvas-menu');
                  $this.addClass('active');
              }
          })

          $('.site-mobile-menu-body a').on('click', function (e) {
            $('body').removeClass('offcanvas-menu')
            $('.js-menu-toggle').removeClass('active')
          })

          // click outisde offcanvas
          $(document).mouseup(function(e) {
              var container = $(".site-mobile-menu");
              if (!container.is(e.target) && container.has(e.target).length === 0) {
                  if ( $('body').hasClass('offcanvas-menu') ) {
                      $('body').removeClass('offcanvas-menu');
                  }
              }
          });
      };
      siteMenuClone();



      var sitePlusMinus = function() {
          $('.js-btn-minus').on('click', function(e){
              e.preventDefault();
              if ( $(this).closest('.input-group').find('.form-control').val() != 0  ) {
                  $(this).closest('.input-group').find('.form-control').val(parseInt($(this).closest('.input-group').find('.form-control').val()) - 1);
              } else {
                  $(this).closest('.input-group').find('.form-control').val(parseInt(0));
              }
          });
          $('.js-btn-plus').on('click', function(e){
              e.preventDefault();
              $(this).closest('.input-group').find('.form-control').val(parseInt($(this).closest('.input-group').find('.form-control').val()) + 1);
          });
      };
      // sitePlusMinus();


      var siteSliderRange = function() {
          $( "#slider-range" ).slider({
              range: true,
              min: 0,
              max: 500,
              values: [ 75, 300 ],
              slide: function( event, ui ) {
                  $( "#amount" ).val( "$" + ui.values[ 0 ] + " - $" + ui.values[ 1 ] );
              }
          });
          $( "#amount" ).val( "$" + $( "#slider-range" ).slider( "values", 0 ) +
              " - $" + $( "#slider-range" ).slider( "values", 1 ) );
      };
      // siteSliderRange();


      var siteMagnificPopup = function() {
          $('.image-popup').magnificPopup({
              type: 'image',
              closeOnContentClick: true,
              closeBtnInside: false,
              fixedContentPos: true,
              mainClass: 'mfp-no-margins mfp-with-zoom', // class to remove default margin from left and right side
              gallery: {
                  enabled: true,
                  navigateByImgClick: true,
                  preload: [0,1] // Will preload 0 - before current, and 1 after the current image
              },
              image: {
                  verticalFit: true
              },
              zoom: {
                  enabled: true,
                  duration: 300 // don't foget to change the duration also in CSS
              }
          });

          $('.popup-youtube, .popup-vimeo, .popup-gmaps').magnificPopup({
              disableOn: 700,
              type: 'iframe',
              mainClass: 'mfp-fade',
              removalDelay: 160,
              preloader: false,

              fixedContentPos: false
          });
      };
      siteMagnificPopup();


      var siteCarousel = function () {
          if ( $('.nonloop-block-13').length > 0 ) {
              $('.nonloop-block-13').owlCarousel({
                  center: false,
                  items: 1,
                  loop: true,
                  stagePadding: 0,
                  margin: 0,
                  autoplay: true,
                  nav: true,
                  navText: ['<i class="material-icons">keyboard_arrow_left</i>', '<i class="material-icons">keyboard_arrow_right</i>'],
                  responsive:{
                      600:{
                          margin: 0,
                          nav: true,
                          items: 2
                      },
                      1000:{
                          margin: 0,
                          stagePadding: 0,
                          nav: true,
                          items: 3
                      },
                      1200:{
                          margin: 0,
                          stagePadding: 0,
                          nav: true,
                          items: 4
                      }
                  }
              });
          }

          $('.slide-one-item').owlCarousel({
              center: false,
              items: 1,
              loop: true,
              stagePadding: 0,
              margin: 0,
              autoplay: true,
              pauseOnHover: false,
              nav: true,
              navText: ['<i class="material-icons">keyboard_arrow_left</i>', '<i class="material-icons">keyboard_arrow_right</i>']
          });

          $('.card-slider').owlCarousel({
            items: 4,
            margin: 50,
            stagePadding: 0,
            smartSpeed: 450,
            nav: true,
            navText: ['<i class="material-icons">keyboard_arrow_left</i>', '<i class="material-icons">keyboard_arrow_right</i>'],
            responsive:{
              0:{
                  items:1,
                  margin: 0,
                  center: true
              },
              600:{
                  items:2
              },
              993:{
                  items:3
              },
              1200:{
                  items:4
              }
            }
          });
      };
      siteCarousel();

      var siteStellar = function() {
          $(window).stellar({
              responsive: false,
              parallaxBackgrounds: true,
              parallaxElements: true,
              horizontalScrolling: false,
              hideDistantElements: false,
              scrollProperty: 'scroll'
          });
      };
      siteStellar();

      var siteCountDown = function() {

          $('#date-countdown').countdown('2020/10/10', function(event) {
              var $this = $(this).html(event.strftime(''
                  + '<span class="countdown-block"><span class="label">%w</span> weeks </span>'
                  + '<span class="countdown-block"><span class="label">%d</span> days </span>'
                  + '<span class="countdown-block"><span class="label">%H</span> hr </span>'
                  + '<span class="countdown-block"><span class="label">%M</span> min </span>'
                  + '<span class="countdown-block"><span class="label">%S</span> sec</span>'));
          });

      };
      siteCountDown();

      var siteDatePicker = function() {

          if ( $('.datepicker').length > 0 ) {
              $('.datepicker').datepicker();
          }

      };
      siteDatePicker();

      // scroll
      var scrollWindow = function() {
          $(window).scroll(function(){
              var $w = $(this),
                  st = $w.scrollTop(),
                  navbar = $('.js-site-navbar'),
                  sd = $('.js-scroll-wrap'),
                  toggle = $('.site-menu-toggle');

              if ( toggle.hasClass('open') ) {
                  $('.site-menu-toggle').trigger('click');
              }


              if (st > 150) {
                  if ( !navbar.hasClass('scrolled') ) {
                      navbar.addClass('scrolled');
                      $('#scroll_assist').fadeIn()
                  }
              }
              if (st < 150) {
                  if ( navbar.hasClass('scrolled') ) {
                      navbar.removeClass('scrolled sleep');
                      $('#scroll_assist').fadeOut()
                  }
              }
              if ( st > 350 ) {
                  if ( !navbar.hasClass('awake') ) {
                      navbar.addClass('awake');
                  }

                  if(sd.length > 0) {
                      sd.addClass('sleep');
                  }
              }
              if ( st < 350 ) {
                  if ( navbar.hasClass('awake') ) {
                      navbar.removeClass('awake');
                      navbar.addClass('sleep');
                  }
                  if(sd.length > 0) {
                      sd.removeClass('sleep');
                  }
              }
          });
      };
      scrollWindow();


      // active active nav link
      $('[role="navigation"] .nav-link, .site-mobile-menu .nav-link').each(function () {
          if (this.href === window.location.href) {
              $(this).addClass('active')
          }
      })

      // booking page
      $(".booking-calendar").sticky({ topSpacing: 40 });

      $('#bookingsCalendarToggle, #categoryCalendarToggle').on('click', function () {
        $('.custom-calendar-wrap, .custom-calendar-modal-shadow').addClass('active')
      })

      $('.custom-calendar-modal-shadow, .custom-calendar-modal-toolbar .close-button').on('click', function () {
        $('.custom-calendar-wrap, .custom-calendar-modal-shadow').removeClass('active')
      })

      $('#bookings-circle').circleProgress({
        value: 0.85,
        size: 30,
        fill: {
          gradient: ["#00878c"]
        }
      });

      $('.material-tabs').each(function() {
          var $active, $content, $links = $(this).find('a');

          $active = $($links[0]);
          $active.addClass('active');

          $content = $($active[0].hash);

          $links.not($active).each(function() {
              $(this.hash).hide();
          });

          $(this).on('click', 'a', function(e) {

              $active.removeClass('active');
              $content.hide();

              $active = $(this);
              $content = $(this.hash);

              $active.addClass('active');
              $content.show();

              e.preventDefault();
          });
      });
  });
