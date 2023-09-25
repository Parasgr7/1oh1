$(document).on('turbolinks:load', function() {
    // listeners
    $('#btnCreateNewAccount').on('click', function (event) {
      event.preventDefault()
      $('.auth-pages').addClass('d-none')

      $('#modal_signup').removeClass('d-none')
    })

    $('#btnSignInNextPage').on('click', function (event) {
      event.preventDefault()

      var isValid = $('#sign-in-form').valid()
      if (!isValid) return

      $(this).prop('disabled', 'disabled').text('loading...')

      $.get('/user_login?email=' + $('#signInEmail').val(), function (data) {
        if (data.url) $('#signin_password_profile_picture').prop('src', data.url)
      }).always(function () {
        $('#btnSignInNextPage').prop('disabled', false).text('Continue')

        $('.auth-pages').addClass('d-none')

        $('#modal_sign_in_password').removeClass('d-none')
      })

      $('#SignInProfileEmail').text($('#signInEmail').val())
    })

    $('#btnSignInForgotPasswordBack').on('click', function (event) {
      event.preventDefault()
      $('.auth-pages').addClass('d-none')

      $('#modal_sign_in_password').removeClass('d-none')
    })

    $('#signUpGoToSignIn').on('click', function (event) {
      event.preventDefault()
      $('.auth-pages').addClass('d-none')

      $('#modal_sign_in_email').removeClass('d-none')
    })

    $('#signInGotoResetPassword').on('click', function (event) {
      event.preventDefault()
      $('.auth-pages').addClass('d-none')

      $('#modal_sign_in_forgot_password').removeClass('d-none')
    })

    $('#signInGotoFirstPage').on('click', function (event) {
      event.preventDefault()
      $('.auth-pages').addClass('d-none')

      $('#modal_sign_in_email').removeClass('d-none')
    })

    $('.cd-signin').on('click', function(event){
      event.preventDefault()
      $('#authDialog').modal()

      $('.auth-pages').addClass('d-none')

      $('#modal_sign_in_email').removeClass('d-none')

      setTimeout(focusOnfirstInputInSignIn, 700)
    })

    $('.cd-signup').on('click', function(event){
      event.preventDefault()
      $('#authDialog').modal()

      $('.auth-pages').addClass('d-none')

      $('#modal_signup').removeClass('d-none')

      setTimeout(focusOnfirstInputInSignUp, 700)
    });

    $('#termsAndConditionDialogBtn').on('click', function () {
      $('#termsAndConditions').modal()
    })

    $('#privacyPolicyDialogBtn').on('click', function () {
      $('#privacyPolicy').modal()
    })


    $('#termsAndConditions').on('shown.bs.modal', function () {
      $('body').addClass('modal-open')
    })

    $('#privacyPolicy').on('shown.bs.modal', function () {
      $('body').addClass('modal-open')
    })

    $('#termsAndConditions').on('hidden.bs.modal', function () {
      $('#authDialog').modal()
    })

    $('#privacyPolicy').on('hidden.bs.modal', function () {
      $('#authDialog').modal()
    })

    $('#signup-email').keyup(function () {
      $('#waitingForVerification').val($(this).val())
    })
    //hide or show password
    $('.hide-password').on('click', function(event){
        event.preventDefault()
        var $this= $(this)
        var $password_field = $this.prevAll('input')
        // PasswordField-VisibilityToggle__Icon
        if ($password_field.attr('type') === 'text') {
          $password_field.attr('type', 'password')

        } else {
          $password_field.attr('type', 'text')

        }

        $this.find('.PasswordField-toggle-icon').toggleClass('d-none')
        //focus and move cursor to the end of input field
        $password_field.putCursorAtEnd();
    });

    $('#signInEmail').keydown(function (e){
        if (e.keyCode === 13) {
          e.preventDefault()
          $('#btnSignInNextPage').click()
        }
    })
    $('#signInPassword').keydown(function (e){
        if (e.keyCode === 13) {
          e.preventDefault()
          $('#modal_sign_in_password input[type=submit]').click()
        }
    })
    function focusOnfirstInputInSignIn () {
        var firstInput = document.querySelector('#signInEmail')
        if (firstInput) firstInput.focus()
    }
    function focusOnfirstInputInSignUp () {
        var firstInput = document.querySelector('#signup-firstName')
        if (firstInput) firstInput.focus()
    }



    // validations
    $('#reset-password-form').each(function() {  // attach to all form elements on page
        $(this).validate({
            submitHandler: function(form) {
              form.submit()
            }
        })
    })

    $('#new_user form').validate({
        rules: {
            'user[password_confirmation]': {
              equalTo: '#new_user [name="user[password]"]'
            }
        },
        messages: {
            'user[password_confirmation]': {
                equalTo: 'Password and confirm password does not match.'
            }
        }
    })

    // password strength meter
    function passwordMeter (password) {
        let strengthValue = {
            'caps': false,
            'length': false,
            'special': false,
            'numbers': false,
            'small': false
        };

        if(password.length >= 8) {
            strengthValue.length = true;
        }

        for(let index=0; index < password.length; index++) {
            let char = password.charCodeAt(index);
            if(!strengthValue.caps && char >= 65 && char <= 90) {
                strengthValue.caps = true;
            } else if(!strengthValue.numbers && char >=48 && char <= 57){
                strengthValue.numbers = true;
            } else if(!strengthValue.small && char >=97 && char <= 122){
                strengthValue.small = true;
            } else if(!strengthValue.numbers && char >=48 && char <= 57){
                strengthValue.numbers = true;
            } else if(!strengthValue.special && (char >=33 && char <= 47) || (char >=58 && char <= 64)) {
                strengthValue.special = true;
            }
        }

        let strengthIndicator = 0;

        for (let metric in strengthValue) {
            if(strengthValue[metric] === true) {
                strengthIndicator++;
            }
        }

        return strengthIndicator
    }

    var password = document.querySelector('#new_user [name="user[password]"]');
    var text = document.getElementById('password-strength-text');

    let strength = {
        0: '<span style="color: #CC0000">Not Secure</span>',
        1: '<span style="color: #ff4444">Weak</span>',
        2: '<span style="color: #ffbb33">Fair</span>',
        3: '<span style="color: #00C851">Good</span>',
        4: '<span style="color: #007E33">Strong</span>'
    };

    if (password)
    {
      password.addEventListener('keyup', function() {
          var val = password.value
          var score = passwordMeter(val)

          // Update the text indicator
          if (val !== "") {
              password.classList.add('has-strength')

              text.innerHTML = "PW strength: " + strength[score];
          } else {
              password.classList.remove('has-strength')

              text.innerHTML = "";
          }
      });
    }

});

//credits https://css-tricks.com/snippets/jquery/move-cursor-to-end-of-textarea-or-input/
jQuery.fn.putCursorAtEnd = function() {
    return this.each(function() {
        // If this function exists...
        if (this.setSelectionRange) {
            // ... then use it (Doesn't work in IE)
            // Double the length because Opera is inconsistent about whether a carriage return is one character or two. Sigh.
            var len = $(this).val().length * 2;
            this.setSelectionRange(len, len);
        } else {
            // ... otherwise replace the contents with itself
            // (Doesn't work in Google Chrome)
            $(this).val($(this).val());
        }
    });
};
