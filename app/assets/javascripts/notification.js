$(document).on('turbolinks:load', function() {
  notification();

//   $("#notification").on('click',function(){
//     console.log($(".site-menu li.has-children"))
//     $(".site-menu li.has-children").focus();
//   });
//
//   jQuery(document.body).on('click', 'a.unread', function(event){
//     var notif_id =  $(this).attr("id");
//     $.ajax({
//            url: "/notifications/"+notif_id+"/mark_as_read/",
//            dataType: "JSON",
//            type: "POST",
//            success: function(result){
//              console.log(result);
//        }});
// });
});

function notification (data)
{
  function setNotif (result) {
    if (!result["unread"]) return

    if (result["unread"] != 0) {
      $("#notification > #unread_count").text(result["unread"]).addClass('active')
    } else {
      $("#notification > #unread_count").removeClass('active')
    }
  }

  if (!data) {
    $.ajax({
            url: "/notifications.json",success(data){setNotif(data)}})
  } else {
    setNotif(data)
  }
}
