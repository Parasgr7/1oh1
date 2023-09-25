$(document).ready(function () {
  var debouncedInit = debounce(initMessages, 250)

  $(document).on('turbolinks:load', debouncedInit)

  debouncedInit()

  var unsavedChangesEvent
  var unsavedChangesElmTrack
  var onContinueClicked = false
  function initMessages () {
    $('#backToConversation').on('click', function () {
      $('#conversationColumn').removeClass('d-none')

      $('#chatColumn').addClass('d-none')
    })

    //modal for unsavedChangesDialog dialog
    $(document).on("click", "a", function (e) {
        var that = this
        
        if (document.getElementById('contenteditableMessageBox')) {
          $('#message_content').val(document.getElementById('contenteditableMessageBox').innerText.trim())
        }

        if (!onContinueClicked && !$(this).hasClass('message-send-btn') && $('#message_content').val()) {
          e.preventDefault()
          var event = e.originalEvent

          unsavedChangesEvent = new MouseEvent(event.type, event)
          unsavedChangesElmTrack = $(that).get(0)

          $("#messageNotSentDialog").modal("show")
        }
    })

    $('#dialogMessageNotSentContinueBtn').click(function () {
      if (unsavedChangesEvent) {
        onContinueClicked = true
        unsavedChangesElmTrack.dispatchEvent(unsavedChangesEvent)
      }
    })
  }

  function debounce (func, wait, immediate) {
    var timeout;
    return function() {
      var context = this, args = arguments;
      var later = function() {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    }
  }
})
