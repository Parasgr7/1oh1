// broswer polyfil
navigator.getUserMedia = ( navigator.getUserMedia ||
navigator.webkitGetUserMedia ||
navigator.mozGetUserMedia ||
navigator.msGetUserMedia)

var iceServers = [{
    urls: 'stun:stun.privatechat.app:5349'
  }, {
    urls: 'turn:turn.privatechat.app:5349',
    username: 'brucewayne',
    credential: 'brucewayne'
}]


// Broadcast Types
const JOIN_ROOM = "JOIN_ROOM";
const EXCHANGE = "EXCHANGE";
const REMOVE_USER = "REMOVE_USER";
const TOGGLE_VIDEO = "TOGGLE_VIDEO"
// configs
var displayMediaStreamConstraints = {
  video: true,
    audio:{
    googEchoCancellation: false,
    googAutoGainControl: false,
    googNoiseReduction: false
  }
};

var mediaStreamConstraints = {
  video: {
    width: screen.width,
    height: screen.height,
    aspectRatio: 1.77
  },
  audio:{
    googEchoCancellation: false,
    googAutoGainControl: false,
    googNoiseReduction: false
  }
}
// DOM Elements
let currentUser;
let remoteVideoContainer;
// Objects
let pcPeers = {}
let localStream
let videoDevices
let seesionId
window.onload = async () => {
  currentUser = document.getElementById("current-user").innerHTML;
  end_time = document.getElementsByTagName("time")[0].innerHTML;
  countdown_timer(end_time);
  seesionId = document.getElementById("session_id").innerHTML;
  peer_user_id = document.getElementById("peer-user").innerHTML;
  remoteVideoContainer = document.getElementById("remote-video-container");

  var preSessionTimerElm = $('#pre_session_start_time')
  var preSessionCountDown = moment(preSessionTimerElm.attr('data-count-down')).toDate()

  try {
    localStream = await navigator.mediaDevices.getUserMedia(mediaStreamConstraints)
  } catch (e) {
    $('#preSessionErrorContainer').text('Please make sure audio and video are enabled, then refresh the page.').show()
    return
  }

  $('#local-video').get(0).srcObject = localStream

  const devices = await navigator.mediaDevices.enumerateDevices()
  videoDevices = devices.filter(x => x.kind === 'videoinput')

  setVideoDevicesLabels()


  if (videoDevices.length < 2) {
    $('.pre-session-switch-camera').hide()
  }
  $('.dropdown-submenu button.test').on('click', function (e) {
    $(this).next('ul').toggle()
    e.stopPropagation()
    e.preventDefault()
  })

  if (moment().isAfter(moment(preSessionCountDown))) {
    $('#join-session-btn').prop('disabled', false)
  }

  $('#otherUserEndedSessionConfirmBtn').on('click', function () {
    localStream.getTracks().forEach(function (track) {
      track.stop()
    })
    $('#timesUp').modal({
      backdrop: 'static'
    })
    var otherUserDisplayName = $('#otherUserDisplayNamePlaceholder').text()
    $('#timesUpModalTitle').text(otherUserDisplayName + ' has ended the session')
  })
  $('#endSessionConfirmBtn').on('click', function () {
    handleLeaveSession()
  })
  // start count down
  preSessionTimerElm.countdown(preSessionCountDown, function(event) {
    $(this).text(event.strftime('%H:%M:%S'))
  }).on('finish.countdown', function() {
    console.log('finished')
      $('#join-session-btn').prop('disabled', false)
      preSessionTimerElm.text('ready')
  })
};

function hasTimeLeft (end_time) {
  var countDownDate = new Date(end_time).getTime();

  var now = new Date().getTime();

  var distance = countDownDate - now;

  if (distance > 0) return true
  else return false
}

function setVideoDevicesLabels () {
  $('#videoDevicesList').html('')

  var labels = videoDevices.map(function (device) {
    return {
      label: device.label,
      deviceId: device.deviceId
    }
  }).forEach(function (device) {
    var elem = $('<a data-turbolinks="false" class="dropdown-item fsz-14" href="#">' + device.label + '</a>')
    elem.on('click', function () {
      switchCameras(device.deviceId)
    })

    $('#videoDevicesList').append(elem)
  })
}

function countdown_timer(end_time)
{

  countDownDate= new Date(end_time).getTime();

  var x = setInterval(function() {

    var now = new Date().getTime();

    var distance = countDownDate - now;

    // Time calculations for days, hours, minutes and seconds
    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((distance % (1000 * 60)) / 1000);

    // Output the result in an element with id="demo"
    days = days?days+"d ":"";
    hours = hours?hours+"h ":"";
    minutes = minutes?minutes+"m ":"";
    seconds = seconds?seconds+"s ":"";

    if (!document.getElementById("demo")) {
      clearInterval(x)
      return
    }
    document.getElementById("demo").innerHTML = days + hours+ minutes+ seconds;

    // If the count down is over, write some text
    if (distance < 0) {
      clearInterval(x)
      document.getElementById("demo").innerHTML = "EXPIRED"
      $('#timesUp').modal({
        backdrop: 'static'
      });
       localStream.getTracks().forEach(function (track) {
         track.stop()
       })
      $('#local-video-right').hide()
  }
}, 1000)

}
// Ice Credentials
const ice = { iceServers: iceServers };

const handleJoinSession = async () => {
  //Here to fadeOut the middlecam and add to topbarcam
  $('.wrapCardPre').fadeOut();
  $('#local-video-up').fadeIn();
  $('.session_header_text').show()

  localVideoUp = document.getElementById("local-video-right")
  localVideoUp.srcObject = localStream

  App.session = await App.cable.subscriptions.create({channel: 'SessionChannel',session_id: document.getElementById("session_id").innerHTML },
  { connected: () => {
      broadcastData({
        type: JOIN_ROOM,
        from: currentUser,
        session_id: seesionId
      });
      $('#loading').show()
  },
    received: data => {
      console.log("received", data);
      if (data.from === currentUser) return;
      switch (data.type) {
        case JOIN_ROOM:
          return joinRoom(data);
        case EXCHANGE:
          if (data.to !== currentUser) return;
          return exchange(data);
        case REMOVE_USER:
          return removeUser(data);
        default:
        case TOGGLE_VIDEO:
          return opponentToggledVideo(data.candidate)
          break
          return;
      }
    },
    speak: messageBody => {
      console.log("received", messageBody);
      return App.session.perform('speak', { body: messageBody });
      }
  });
};

const opponentToggledVideo = (active) => {
  if (active) {
    $('#opponent_disabled_video').hide()
  } else {
    $('#opponent_disabled_video').show()
  }
}

const onLeaveSessionClick = () => {
  $('#endSessionDialog').modal()
}

const handleLeaveSession = () => {
  for (user in pcPeers) {
    pcPeers[user].close();
  }
  // $('#closed').modal('show');
  pcPeers = {};

  App.session.unsubscribe();

  if (remoteVideoContainer) remoteVideoContainer.innerHTML = "";

  broadcastData({
    type: REMOVE_USER,
    from: currentUser,
    to: 'CLOSED_SESSION',
    session_id: seesionId
  });

  localStream.getTracks().forEach(function(track) {
    track.stop();
  });

  Turbolinks.visit('/chests?id='+seesionId+'&profile_id='+currentUser+'&peer_id='+peer_user_id)
};

const handleToggleScreenShare = function (type) {
  var container = document.getElementById('toggle-screen-btn')

  if (container.classList.contains('active')) {
    container.classList.remove('active')

    navigator.mediaDevices.getUserMedia(mediaStreamConstraints).then(function (stream) {
      replaceTracks(stream);
      localStream = stream;
      localVideoUp = document.getElementById("local-video-right");
      localVideoUp.srcObject = stream

      document.getElementById('toggle-audio-btn').classList.remove('active')
      document.getElementById('toggle-video-btn').classList.remove('active')
    }).catch(function (error) {
      container.classList.toggle('active')
    })
  } else {
    if (type === 'on-chrome-btn') return

    container.classList.add('active')

    if (navigator.mediaDevices.getDisplayMedia) {
        navigator.mediaDevices.getDisplayMedia(displayMediaStreamConstraints)
        .then(stream => {
          localStream.getTracks().forEach(function(track) {
            if (track.kind !== 'audio') track.stop();
          });

          replaceTracks(stream, true);
          localStream = stream;
          stream.getVideoTracks()[0].onended = function () {
            handleToggleScreenShare('on-chrome-btn')
          };

          localVideoUp = document.getElementById("local-video-right");
          localVideoUp.srcObject = stream;
        })
        .catch(function (error) {
          container.classList.toggle('active')
        });
    }
  }
}

var currentActiveCamera = 0
async function switchCameras (cameraId) {
  if (!cameraId) {
    var nextCamera = videoDevices[currentActiveCamera + 1]

    if (nextCamera) {
      mediaStreamConstraints.video.deviceId = {exact: nextCamera.deviceId}
      currentActiveCamera = currentActiveCamera + 1
    } else {
      mediaStreamConstraints.video.deviceId = {exact: videoDevices[0].deviceId}
      currentActiveCamera = 0
    }
  } else {
    mediaStreamConstraints.video.deviceId = {exact: cameraId}
  }

  navigator.mediaDevices.getUserMedia(mediaStreamConstraints).then(function(_stream) {
    // if we are communicating
    if (Object.keys(pcPeers).length) {
      replaceTracks(_stream)
      localStream = _stream
      localVideoUp = document.getElementById("local-video-right")
      localVideoUp.srcObject = _stream
    } else {
      localStream = _stream
      localVideoUp = document.getElementById("local-video-right")
      localVideoUp.srcObject = _stream

      var preSessionLocalVideo = document.getElementById('local-video')
      preSessionLocalVideo.srcObject = _stream
    }
  }).catch(function(err) {
    console.log(err)
  })
}

function replaceTracks(newStream, keepAudio) {
  var newStreamTracks = newStream.getTracks()
  var peer = pcPeers[Object.keys(pcPeers)[0]]
  var senders = peer.getSenders()

  newStreamTracks.forEach(function(track) {
     localStream.addTrack(track);
  });

  _replaceTracksForPeer(peer);

  function _replaceTracksForPeer(peer) {
    senders.map(function(sender) {
        if (!sender.track) return

        var targetTrack = newStreamTracks.find(function(track) {
            return track.kind === sender.track.kind
        })

        if (!targetTrack) return

        sender.replaceTrack(targetTrack);
    });
  }
}


const handleToggleAudio = function (wraperIds) {
  wraperIds.forEach(function (id) {
    var container = document.getElementById(id)

    container.classList.toggle('active')
  })

  var audioTracks = localStream.getAudioTracks()

  if (audioTracks.length === 0) return

  for (var i = 0; i < audioTracks.length; ++i) {
    audioTracks[i].enabled = !audioTracks[i].enabled
  }
}

const handleToggleVideo = function (wraperIds) {
  if (wraperIds) {
    wraperIds.forEach(function (id) {
      var container = document.getElementById(id)

      container.classList.toggle('active')
    })
  }

  var videoTracks = localStream.getVideoTracks()

  if (videoTracks.length === 0) return
  var isEnabled
  for (var i = 0; i < videoTracks.length; ++i) {
    videoTracks[i].enabled = !videoTracks[i].enabled

    isEnabled = videoTracks[i].enabled
  }

  broadcastData({
    type: TOGGLE_VIDEO,
    from: currentUser,
    session_id: seesionId,
    candidate: isEnabled
  });

  if (isEnabled) {
    $('.video-background-overlay').hide()

    $('.pre-session-switch-camera').prop('disabled', false)
  } else {
    $('.video-background-overlay').show()

    $('.pre-session-switch-camera').prop('disabled', 'disabled')
  }
}

const handleOpenFullscreen = function () {
  var elem = document.querySelector('#remote-video-container video')
  if (elem.requestFullscreen) {
    elem.requestFullscreen();
  } else if (elem.mozRequestFullScreen) { /* Firefox */
    elem.mozRequestFullScreen();
  } else if (elem.webkitRequestFullscreen) { /* Chrome, Safari and Opera */
    elem.webkitRequestFullscreen();
  } else if (elem.msRequestFullscreen) { /* IE/Edge */
    elem.msRequestFullscreen();
  }
}

const joinRoom = data => {
  createPC(data.from, true);
};

const removeUser = data => {
  console.log("removing user", data.from);
  let video = document.getElementById(`remoteVideoContainer+${data.from}`);
  video && video.remove();
  delete pcPeers[data.from];
  $('div#show').hide();

  if (data.to === 'CLOSED_SESSION') { //other user canceled the session
    $('#otherUserEndedSession').modal({
      backdrop: 'static'
    })
  }
};

const createPC = (userId, isOffer) => {
  let pc = new RTCPeerConnection(ice);
  pcPeers[userId] = pc;
  pc.addStream(localStream);

  isOffer &&
    pc
      .createOffer()
      .then(offer => {
        return pc.setLocalDescription(offer);
      }).then(() => {
        broadcastData({
          type: EXCHANGE,
          from: currentUser,
          session_id: seesionId,
          to: userId,
          sdp: JSON.stringify(pc.localDescription)
        });
      })
      .catch(logError);

  pc.onicecandidate = event => {
    event.candidate &&
      broadcastData({
        type: EXCHANGE,
        from: currentUser,
        session_id: seesionId,
        to: userId,
        candidate: JSON.stringify(event.candidate)
      });
  };

  pc.onaddstream = event => {
    const element = document.createElement("video");
    element.id = `remoteVideoContainer+${userId}`;
    element.autoplay = "autoplay";
    element.srcObject = event.stream;
    remoteVideoContainer.appendChild(element);
    $('div#show').toggle();

  };

  pc.oniceconnectionstatechange = event => {
    if (pc.iceConnectionState == "disconnected") {
      console.log("Disconnected:", userId);
      $('#loading').show()
      broadcastData({
        type: REMOVE_USER,
        from: userId,
        session_id: seesionId
      });

      setTimeout(function (argument) {
        broadcastData({
        type: JOIN_ROOM,
          from: currentUser,
          session_id: seesionId
        });
      }, 1500)
    }
  };

  return pc;
};

const exchange = data => {
  $('#loading').hide()
  let pc;

  if (!pcPeers[data.from]) {
    pc = createPC(data.from, false);
  } else {
    pc = pcPeers[data.from];
  }

  if (data.candidate) {
    pc
      .addIceCandidate(new RTCIceCandidate(JSON.parse(data.candidate)))
      .then(() => console.log("Ice candidate added"))
      .catch(logError);
  }

  if (data.sdp) {
    sdp = JSON.parse(data.sdp);
    pc
      .setRemoteDescription(new RTCSessionDescription(sdp))
      .then(() => {
        if (sdp.type === "offer") {
          pc.createAnswer().then(answer => {
            return pc.setLocalDescription(answer);
          }).then(()=> {
            broadcastData({
              type: EXCHANGE,
              from: currentUser,
              session_id: seesionId,
              to: data.from,
              sdp: JSON.stringify(pc.localDescription)
            });
          });
        }
      })
      .catch(logError);
  }
};

const broadcastData = data => {
  fetch('/sessions', {
    method: "POST",
    body: JSON.stringify(data),
    headers: { "content-type": "application/json" }
  });
};

const logError = error => console.warn("Whoops! Error:", error);
