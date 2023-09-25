$(document).on('turbolinks:load', function() {

    // Dropdown menu
    $(".sidebar-dropdown > a").click(function () {
        $(".sidebar-submenu").slideUp(200);
        if ($(this).parent().hasClass("active")) {
            $(".sidebar-dropdown").removeClass("active");
            $(this).parent().removeClass("active");
        } else {
            $(".sidebar-dropdown").removeClass("active");
            $(this).next(".sidebar-submenu").slideDown(200);
            $(this).parent().addClass("active");
        }

    });

    //toggle sidebar
    $("#responsiveMenu").click(function () {
        $(".page-wrapper").toggleClass("toggled");
    });
    $("#toggle-sidebar").click(function () {
        $(".page-wrapper").toggleClass("toggled");
    });
    $(".memberViewMobile").click(function () {
        $(".page-wrapper").toggleClass("toggled");
    })
    $("#toggle-exit").click(function () {
        $(".page-wrapper").toggleClass("toggled");
    });
    //Pin sidebar
    $("#pin-sidebar").click(function () {
        if ($(".page-wrapper").hasClass("pinned")) {
            // unpin sidebar when hovered
            $(".page-wrapper").removeClass("pinned");
            $("#sidebar").unbind( "hover");
        } else {
            $(".page-wrapper").addClass("pinned");
            $("#sidebar").hover(
                function () {
                    console.log("mouseenter");
                    $(".page-wrapper").addClass("sidebar-hovered");
                },
                function () {
                    console.log("mouseout");
                    $(".page-wrapper").removeClass("sidebar-hovered");
                }
            )

        }
    });


    //toggle sidebar overlay
    $("#sidebar-overlay").click(function () {
        $(".page-wrapper").toggleClass("toggled");
    });

    //switch between themes
    var themes = "default-theme legacy-theme chiller-theme ice-theme cool-theme light-theme";
    $('[data-theme]').click(function () {
        $('[data-theme]').removeClass("selected");
        $(this).addClass("selected");
        $('.page-wrapper').removeClass(themes);
        $('.page-wrapper').addClass($(this).attr('data-theme'));
    });

    // switch between background images
    var bgs = "bg1 bg2 bg3 bg4";
    $('[data-bg]').click(function () {
        $('[data-bg]').removeClass("selected");
        $(this).addClass("selected");
        $('.page-wrapper').removeClass(bgs);
        $('.page-wrapper').addClass($(this).attr('data-bg'));
    });

    // toggle background image
    $("#toggle-bg").change(function (e) {
        e.preventDefault();
        $('.page-wrapper').toggleClass("sidebar-bg");
    });

    // toggle border radius
    $("#toggle-border-radius").change(function (e) {
        e.preventDefault();
        $('.page-wrapper').toggleClass("boder-radius-on");
    });

    //custom scroll bar is only used on desktop
    if (!/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {

        $(".sidebar-content").addClass("desktop");
    }


    var sidebar = document.querySelector("#sidebar");
    var reviews = document.querySelector(".reviewsPage");
    if(sidebar || reviews){
      var topbar = document.querySelector("#site-navbar");
      if(topbar){
        topbar.classList.add("topbarSide");
      }
    }

    var URLMarket = window.location.href;
    if (URLMarket.indexOf("markets") != -1 || URLMarket.indexOf("/profile/") != -1) {
        var topbarMarket = document.querySelector("#site-navbar");
        if (!topbarMarket) return
        topbarMarket.classList.add("markettopbarSide");
    }

    loadAnimationIcons()

    function loadAnimationIcons () {
        var iconPath = 'https://maxst.icons8.com/vue-static/landings/animated-icons/icons/'
        $('.animated-svg').each(function (index, elm) {
            if ($(elm).children().length > 0) return

            var icon = $(elm).attr('data-icon-source')
            console.log('find')
            var animated = lottie.loadAnimation({
                container: elm, // the dom element
                renderer: 'svg',
                loop: false,
                autoplay: false,
                path: iconPath + icon, // the animation data
            })

            // add hover effect
            var hoverElm
            if ($(elm).hasClass('animated-svg-hover')) hoverElm = $(elm)
            else hoverElm = $(elm).parent('.animated-svg-hover')

            hoverElm.mouseenter(function () {
                animated.stop()
                animated.play()
            })
        })
    }
})

$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
  });

document.addEventListener('turbolinks:before-cache', function(e) {
  $("#explores-tab2-tab").removeClass('active')
  $("#explores-tab3-tab").removeClass('active')
  $("#explores-tab4-tab").removeClass('active')
  $("#tab2-tab").removeClass('active')
  $("#tab3-tab").removeClass('active')
  $(".tab2-tabProfile").removeClass('active')
  $(".tab3-tabProfile").removeClass('active')
  $(".tab2-tabProfile").removeClass('active')
  $(".tab3-tabProfile").removeClass('active')
  $("#profile-tab3-tab").removeClass('active')
  $("#profile-tab2-tab").removeClass('active')
  $("#tab1").show()
  $(".toast").remove()
  $("form#searching-form").trigger('reset')
  $('.animated-svg').html('')
  lottie.destroy()
});
