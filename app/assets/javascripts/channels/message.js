var escapeEntityMap = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
  '/': '&#x2F;',
  '`': '&#x60;',
  '=': '&#x3D;'
};

function escapeHtml (string) {
  return String(string).replace(/[&<>"'`=\/]/g, function (s) {
    return escapeEntityMap[s]
  }).replace(/\n/g, "<br />")
}

function send_message_notification(payload)
{
  $.ajax({
           type: "POST",
           url: '/send_message_notification',
           data: {
             from: payload.user_id,
             to: payload.other_user,
             message: payload.message
           },
           success(data) {
             console.log(data);
           }
   })
}

var getMessageTemplate = function (url, messageContent, type, time,payload) {
  if (type) { // messages for left side
    // if($(window).scrollTop() + $(window).height() == $(document).height()) {
    //     // alert('chat opened, dont send notif');
    // }
    // else{
    //     // alert('No chat opened, send notif');
    //     send_message_notification(payload);
    // }
    return `
    <div class="row message mx-0 mb-2">
      <div class="col-auto px-0">
        <div>
          <div class="avatar"
               style="background-image: url(${url})">
          </div>
        </div>
      </div>
      <div class="col">
        <div class="message-content">
          <span class="mr-2">${time}</span>
           
          ${escapeHtml(messageContent)}
        </div>
      </div>
    </div>`
  } else { // messages for right side(self message display)
    return `
    <div class="message mb-2">
      <div class="text-right">
        <div class="message-content active text-left">
          ${escapeHtml(messageContent)}
        </div>
      </div>
    </div>`
  }
}

function createMessageChannel() {
  App.messages = App.cable.subscriptions.create({
    channel: 'MessageChannel', chat_id: parseInt($("#message_chat_id").val())
    },
    {
    received: function(data) {
      $("#messages").removeClass('hidden')
      return $('#messages').append(this.renderMessage(data));
    },
    renderMessage: function (data) {
      //console.log($("div#messages").children().last().attr('id'));
      var id = Number($("#userIdInfo").text());
      var url = $("#userImageUrl").text();
      setTimeout(function(){
        $('#chatScroll').scrollTop($('#chatScroll')[0].scrollHeight);
      },500);

      $("#chat_form").trigger('reset');
      $('#contenteditableMessageBox').html('')

      return getMessageTemplate(url, data.message, id !== data.user_id,data.time,data)
     },
  });


return App.messages;
}
$(document).on('turbolinks:load', function() {
  var contactListScroll = document.getElementById('chatScroll')
  var messagesScroll = document.getElementById('filterrific_results')
  var contenteditableMessageBox = document.getElementById('contenteditableMessageBox')
  var contenteditableMessageBoxScroll

  if (contactListScroll) new PerfectScrollbar(contactListScroll)
  if (messagesScroll) new PerfectScrollbar(messagesScroll)
  if (contenteditableMessageBox) contenteditableMessageBoxScroll = new PerfectScrollbar(contenteditableMessageBox)

  if (window.location.href.includes('chats')) {
    contactListScroll.scrollTop = contactListScroll.scrollHeight
  }

  $('#contenteditableMessageBox').on('keydown', function (event) {
    if (!event.shiftKey && event.which === 13) {
      event.preventDefault()

      $('#message_content').val(document.getElementById('contenteditableMessageBox').innerText.trim())
      $('#chat_form').submit()
      // submit
    } else if (event.shiftKey && event.which === 13) {
      if (window.getSelection) {
          var selection = window.getSelection(),
              range = selection.getRangeAt(0),
              br = document.createElement("br"),
              textNode = document.createTextNode("\u00a0"); //Passing " " directly will not end up being shown correctly
          range.deleteContents();//required or not?
          range.insertNode(br);
          range.collapse(false);
          range.insertNode(textNode);
          range.selectNodeContents(textNode);

          selection.removeAllRanges();
          selection.addRange(range);
          return false;
      }
    }
  })

  $('#contenteditableMessageBox').on('keyup', function (event) {
    if (event.which === 13) event.preventDefault()
    // body...
  })
})
