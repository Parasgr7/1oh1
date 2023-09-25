jQuery(document).ready(function($) {
  var otherUserCheckBoxValue = true
  var currentUserCheckBoxValue = true

  var calendars = document.querySelectorAll('.timeline-calendar')

  function getAllUrlParams(url) {
  var queryString = url ? url.split('?')[1] : window.location.search.slice(1);
  var obj = {};

  if (queryString) {
    queryString = queryString.split('#')[0];
    var arr = queryString.split('&');
    for (var i = 0; i < arr.length; i++) {
      var a = arr[i].split('=');
      var paramName = a[0];
      var paramValue = typeof (a[1]) === 'undefined' ? true : a[1];

      paramName = paramName.toLowerCase();
      if (typeof paramValue === 'string') paramValue = paramValue.toLowerCase();

      if (paramName.match(/\[(\d+)?\]$/)) {
        var key = paramName.replace(/\[(\d+)?\]/, '');
        if (!obj[key]) obj[key] = [];

        if (paramName.match(/\[\d+\]$/)) {
          var index = /\[(\d+)\]/.exec(paramName)[1];
          obj[key][index] = paramValue;
        } else {
          obj[key].push(paramValue);
        }
      } else {
        if (!obj[paramName]) {
          obj[paramName] = paramValue;
        } else if (obj[paramName] && typeof obj[paramName] === 'string'){
          obj[paramName] = [obj[paramName]];
          obj[paramName].push(paramValue);
        } else {
          obj[paramName].push(paramValue);
        }
      }
    }
  }

  return obj;
}
  params = getAllUrlParams(window.location.href);

  var globalStartTime = '08:00 AM'
  var globalEndTime = '08:30 AM'
  var globalDate = moment().format('D MMM YYYY')

  if (!calendars.length) return
	var timelineCalendar = new FullCalendar.Calendar(calendars[0], getTimelineCalendarConfig())
	window.timelineCalendar = timelineCalendar
  var timelineCalendarMoreOptions = new FullCalendar.Calendar(calendars[1], getTimelineCalendarConfig({
    contentHeight: 400,
    select: function(info) {
      console.log(info);
      var calendarViewType = timelineCalendar.view.type
      var milliseconds = moment.utc(moment(info.end).diff(moment(info.start))).valueOf()
      var minutes = Math.floor(milliseconds / 60000)
      var maximumSlotMinutes = 0

      if (calendarViewType === 'timeGridDay') maximumSlotMinutes = 30
      else maximumSlotMinutes = 1440

      if (minutes > maximumSlotMinutes) {
        timelineCalendar.unselect()
      } else {
        // check for time conflicts
        var events = timelineCalendar.getEvents()
        var hasConflict = events.some(function (event) {
          return hasOverlap(event.start.getTime(), info.start.getTime(), event.end.getTime(), info.end.getTime())
        })

        if (hasConflict) {
          // show conflict error dialog
          $('#newEventTimeConflict').modal()
          return
        }
        // set modal content
        setCreateEventModalMoreOptionContent({
          startTime: moment(info.start).format('hh:mm A'),
          endTime: moment(info.end).format('hh:mm A'),
          setDate: moment(info.start).format('D MMM YYYY')
        })
        globalStartTime = moment(info.start).format('hh:mm A')
        globalEndTime = moment(info.end).format('hh:mm A')
        globalDate = moment(info.start).format('D MMM YYYY')
        // $('#newEventStartTimepicker').val(moment(info.start).format('hh:mm A'))
        // $('#newEventEndTimepicker').val(moment(info.end).format('hh:mm A'))
        //
        // $('#newEventDatePicker').val(moment(info.start).format('D MMM YYYY'))

        // show modal
        // $('#newEventDialog').removeClass('edit-view').modal()

      }
    },
    eventRender: function (info) {
      var description = info.event.extendedProps.eventDescription
      var eventName = info.event.extendedProps.eventName
      var hasStar = info.event.extendedProps.hasStar

      if (description) {
        var descriptionEl = document.createElement('div')
        descriptionEl.innerText = description
        descriptionEl.classList.add('fc-event-description')
        info.el.append(descriptionEl)
      }
      if (eventName) {
        var eventNameEl = document.createElement('div')
        eventNameEl.innerText = eventName
        eventNameEl.classList.add('fc-event-name')
        info.el.append(eventNameEl)
      }
      if (hasStar) {
        var eventStarEl = document.createElement('i')
        eventStarEl.innerText = 'star'
        eventStarEl.classList.add('fc-event-star')
        eventStarEl.classList.add('material-icons')
        info.el.append(eventStarEl)
      }
    }
  }))
  timelineCalendar.render()
  timelineCalendarMoreOptions.render()

  // very custom calendar
  var veryCustomCalendar = document.querySelector('.very-custom-calendar')
  if (!veryCustomCalendar) return
  var veryCustomCalendar = new FullCalendar.Calendar(veryCustomCalendar, {
      plugins: [ 'dayGrid', 'interaction', 'moment' ],
      header: {
        left: '',
        center: '',
        right: ''
      },
      aspectRatio: 1,
      selectable: true,
      select: function(info) {
        if (moment.utc(moment(info.end).diff(moment(info.start))).format('D') > 2) { // disable multi select
          veryCustomCalendar.unselect()
        } else {
          timelineCalendar.gotoDate(info.start)
          setCurrentDateTitle(moment(info.start))

          activeSpecificMonth(moment(info.start).format('M'))
        }
     }
  })

  // render calendar
  veryCustomCalendar.render()

  // apply custom scroll bar
  new PerfectScrollbar(document.querySelector('.months-wrap'))
  new PerfectScrollbar(document.querySelector('.fc-scroller'))

  // initiate timepicker
  $('.new-event-time-picker').mdtimepicker()
  // initiate date picker
  $('.new-event-date-picker').bootstrapMaterialDatePicker({
    weekStart: 0,
    time: false,
    format: 'D MMM YYYY'
  })

  var currentDate = moment(veryCustomCalendar.getDate())
  var prevMonth = currentDate.format('M')

  activeSpecificMonth(prevMonth, true)
  setCurrentDateTitle(currentDate)

  // listeners
  $('.months-wrap .month').on('click', function () {
    var month = $(this).attr('id').replace('month-', '')
    var day = '1'
    var year = currentDate.format('Y')

    // go to specific month
    veryCustomCalendar.gotoDate(moment(month + "-" + day + "-" + year, "MM-DD-YYYY").format())

    activeSpecificMonth(month)
  })

  $('#daily').on('click', function () {
    timelineCalendar.changeView('timeGridDay')
  })

  $('#weekly').on('click', function () {
    timelineCalendar.changeView('dayGridWeek')
  })

  $('#monthly').on('click', function () {
    timelineCalendar.changeView('dayGridMonth')
  })

  $('#booking-add-event-btn').on('click', function () {
    var selectedDate = moment().format('D MMM YYYY')

    $.getScript('/sessions/new', function() {
      var startTime = globalStartTime
      var endTime = globalEndTime
      var setDate = globalDate
      setCreateEventModalContent({
        startTime: startTime,
        endTime: endTime,
        setDate: setDate
      })
      // set defaults
      // $('.start_hidden').val(setDate + ' '+ startTime);
      // $('.end_hidden').val(setDate + ' '+ endTime);

      // listeners
      $('#newEventAddDetailsBtn').on('click', function () {
        showNewEventDetailsTextArea()
      })

      $('#newEventMoreOptionBtn').on('click', function () {
        $('#newEventMoreOptionDialog').modal()

        // set input values
        setCreateEventModalMoreOptionContent({
          startTime: $('#newEventStartTimepicker').val(),
          endTime: $('#newEventEndTimepicker').val(),
          setDate: selectedDate,
          title: $('#booking_title').val(),
          description: $('#newEventAddDetailsTextArea').val()
        })
      })

      // initiate timepicker
      $('.new-event-time-picker').mdtimepicker()
      $('#newEventStartTimepicker').mdtimepicker().on('timechanged', function(e){
        globalStartTime = e.value
          // startTime = e.value
          // $('.start_hidden').val(moment(selectedDate).format('D MMM YYYY') +' '+e.value);
      });
      $('#newEventEndTimepicker').mdtimepicker().on('timechanged', function(e){
          globalEndTime = e.value
          // endTime = e.value
          // $('.end_hidden').val(moment(selectedDate).format('D MMM YYYY') +' '+e.value);
      });
      // initiate date picker
      $('.new-event-date-picker').bootstrapMaterialDatePicker({
        weekStart: 0,
        time: false,
        format: 'D MMM YYYY'
      })
      $('.new-event-date-picker').change(function (e) {
        globalDate = e.target.value
      });

      $('#newEventDialog').removeClass('edit-view').modal()
    })
  })

  $('#more-options-tab2-tab').on('click', function () {
    setTimeout(function () {
      timelineCalendarMoreOptions.updateSize()
    })
  })
  $('#new_booking').submit(function() {
    setCreateEventModalContent({
      startTime: $('#newEventStartTimepickerMoreOption').val(),
      endTime: $('#newEventEndTimepickerMoreOption').val(),
      setDate: $('#newEventDatePickerMoreOption').val(),
      title: $('#newEventSubjectMoreOption').val(),
      description: $('#newEventAddDetailsTextAreaMoreOption').val()
    })
    $('.start_hidden').val(globalDate + ' '+ globalStartTime);
    $('.end_hidden').val(globalDate + ' '+ globalEndTime);
    return true
  })

  $('#newEventMoreOptionTodayBtn').on('click', function () {
    var currentDate = moment()
    timelineCalendarMoreOptions.gotoDate(currentDate.format())

     $('#newEventMoreOptionsCurrentDate').text(currentDate.format('D MMM YYYY'))
  })

  $('#newEventMoreOptionNextDayBtn').on('click', function () {
    var nextDate = moment(timelineCalendarMoreOptions.getDate()).add(1, 'day')
    timelineCalendarMoreOptions.gotoDate(nextDate.format())

    $('#newEventMoreOptionsCurrentDate').text(nextDate.format('D MMM YYYY'))
  })

  $('#newEventMoreOptionPrevDayBtn').on('click', function () {
    var prevDate = moment(timelineCalendarMoreOptions.getDate()).subtract(1, 'day')
    timelineCalendarMoreOptions.gotoDate(prevDate.format())

    $('#newEventMoreOptionsCurrentDate').text(prevDate.format('D MMM YYYY'))
  })

  $('#addNotifButton').on('click', function () {
    addNotif()
  })

  $('#current_user_checkbox').change(function() {
      currentUserCheckBoxValue = this.checked
      refreshEvents()
  })

  $('#other_user_checkbox').change(function() {
      otherUserCheckBoxValue = this.checked
      refreshEvents()
  })
  // methods
  function activeSpecificMonth (currentMonth, scrollToThatMonth) {
    document.getElementById('month-' + prevMonth).classList.remove('active')

    document.getElementById('month-' + currentMonth).classList.add('active')

    prevMonth = currentMonth

    if (scrollToThatMonth) {
      var activeEl = document.querySelector('.months-wrap .active')
      activeEl.scrollIntoView()
    }
  }

  function setCurrentDateTitle (date) {
    var monthEl = document.querySelector('.very-custom-calendar-wrap .calendar-current-date .month-placeholder')
    var dayEl = document.querySelector('.very-custom-calendar-wrap .calendar-current-date .day-placeholder')

    monthEl.innerText = date.format('dddd .')
    dayEl.innerText = date.format('D MMM')
  }

  function hasOverlap (startDate1, startDate2, endDate1, endDate2) {
    return (startDate1 < endDate2 && startDate2 < endDate1)
  }

  function showNewEventDetailsTextArea () {
    $('#newEventAddDetails').removeClass('d-none')
    $('#newEventAddDetailsBtn').addClass('d-none')
  }
  function hideNewEventDetailsTextArea () {
    $('#newEventAddDetails').addClass('d-none')
    $('#newEventAddDetailsBtn').removeClass('d-none')
  }
  function setCreateEventModalContent (info) {
    var start = info.startTime
    var end = info.endTime
    var date = info.setDate
    var title = info.title
    var description = info.description

    $('#newEventStartTimepicker').val(start)
    $('#newEventEndTimepicker').val(end)
    $('#newEventDatePicker').val(date)
    if (title) $('#newEventSubject').val(title)
    else $('#newEventSubject').val('')
    if (description) {
      $('#newEventAddDetailsTextArea').val(description)
      showNewEventDetailsTextArea() // make description visible
    } else {
      $('#newEventAddDetailsTextArea').val('')
      hideNewEventDetailsTextArea()
    }
  }

  function setCreateEventModalMoreOptionContent (info) {
    var start = info.startTime
    var end = info.endTime
    var date = info.setDate
    var title = info.title
    var description = info.description


    $('#newEventStartTimepickerMoreOption').val(start)
    $('#newEventEndTimepickerMoreOption').val(end)
    $('#newEventDatePickerMoreOption').val(date)
    $('#newEventMoreOptionsCurrentDate').text(date)

    $('#newEventDatePickerMoreOption').change(function(){
      globalDate = $('#newEventDatePickerMoreOption').val()

      // newChangedDate = $('#newEventDatePickerMoreOption').val()
      // if (typeof newChangedDate !== 'undefined')
      // {
      //   $('.start_hidden').val(moment(newChangedDate).format('D MMM YYYY') +' '+start);
      //   $('.end_hidden').val(moment(newChangedDate).format('D MMM YYYY') +' '+end);
      // }
      // else {
      //   $('.start_hidden').val(moment(date).format('D MMM YYYY') +' '+start);
      //   $('.end_hidden').val(moment(date).format('D MMM YYYY') +' '+end);
      // }
    })


    $('#newEventStartTimepickerMoreOption').change(function(){
      globalStartTime = $('#newEventStartTimepickerMoreOption').val()
      // if (typeof newChangedDate !== 'undefined')
      // {
      //   $('.start_hidden').val(moment(newChangedDate).format('D MMM YYYY') +' '+startTime);
      // }
      // else {
      //   $('.start_hidden').val(moment(date).format('D MMM YYYY') +' '+startTime);
      // }
    })

    $('#newEventEndTimepickerMoreOption').change(function(){
      globalEndTime = $('#newEventEndTimepickerMoreOption').val()
      // if (typeof newChangedDate !== 'undefined')
      // {
      //   $('.end_hidden').val(moment(newChangedDate).format('D MMM YYYY') +' '+endTime);
      // }
      // else{
      //   $('.end_hidden').val(moment(date).format('D MMM YYYY') +' '+endTime);
      // }
    })


    if (title) $('#newEventSubjectMoreOption').val(title)
    if (description) $('#newEventAddDetailsTextAreaMoreOption').val(description)
  }
  function addNotif () {
    var template = `<div class="position-relative mt-3">
                      <select class="custom-select mr-2 fz-14 gray-input d-inline-block notification-select">
                        <option value="email" selected>Email</option>
                        <option value="notification">Notification</option>
                      </select>

                      <input type="text" class="form-control mr-2 gray-input d-inline-block notification-duration-input" placeholder="30">

                      <select class="custom-select fz-14 gray-input d-inline-block notification-duration-type-input">
                        <option value="minutes" selected>minutes</option>
                        <option value="hours">hours</option>
                        <option value="days">days</option>
                        <option value="weeks">weeks</option>
                      </select>

                      <button type="button" class="d-inline-block btn btn-link btn-link-close" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                      </button>
                  </div>`

    var element = document.createElement('div')
    element.innerHTML = template

    $('#notif-wrap').append(element)

    $(element).find('.btn-link-close').on('click', function () {
      removeNotif($(this))
    })
  }

  function removeNotif (button) {
    $(button).parent().remove()
  }
  function getTimelineCalendarConfig (config) {
    if (!config) config = {}
    return Object.assign({
      header: {
        left: '',
        center: '',
        right: ''
      },
      plugins: [ 'dayGrid', 'timeGrid', 'interaction' ],
      defaultView: 'timeGridDay',
      nowIndicator: true,
      allDaySlot: false,
      contentHeight: 800,
      selectable: true,
      selectHelper: true,
      eventOverlap: false,
      datesRender: function () {
        // initiate custom scroll bar
        Array.from(document.querySelectorAll('.fc-scroller')).forEach(function (el) {
          new PerfectScrollbar(el)
        })
      },
      eventClick: function (info) {

        // $.getScript(info.event.extendedProps.edit_url, function() {
        //   setCreateEventModalContent({
        //     startTime: moment(info.event.start).format('hh:mm A'),
        //     endTime: moment(info.event.end).format('hh:mm A'),
        //     setDate: moment(info.event.start).format('D MMM YYYY'),
        //     title: info.event.title,
        //     description: info.event.extendedProps.eventDescription
        //   })
        //
        //   $('.start_hidden').val(moment(info.event.start).format('D MMM YYYY') +' '+moment(info.event.start).format('hh:mm A'));
        //   $('.end_hidden').val(moment(info.event.start).format('D MMM YYYY') +' '+moment(info.event.end).format('hh:mm A'));
        //
				// 	// add listeners
        //   $('#newEventAddDetailsBtn').on('click', function () {
			  //   	showNewEventDetailsTextArea()
				//   })
        //
				//   $('#newEventMoreOptionBtn').on('click', function () {
				//     $('#newEventMoreOptionDialog').modal()
        //
				//     // set input values
				//     setCreateEventModalMoreOptionContent({
				//       startTime: $('#newEventStartTimepicker').val(),
				//       endTime: $('#newEventEndTimepicker').val(),
				//       setDate: $('#newEventDatePicker').val(),
				//       title: $('#newEventSubject').val(),
				//       description: $('#newEventAddDetailsTextArea').val()
				//     })
				//   })
        //
				// 	 // initiate timepicker
				// 	$('.new-event-time-picker').mdtimepicker()
				//   // initiate date picker
				//   $('.new-event-date-picker').bootstrapMaterialDatePicker({
				//     weekStart: 0,
				//     time: false,
				//     format: 'D MMM YYYY'
				//   })
        //   $('#newEventDialog').addClass('edit-view').modal()
        // });


      },
      select: function(info) {

        var calendarViewType = timelineCalendar.view.type
        var milliseconds = moment.utc(moment(info.end).diff(moment(info.start))).valueOf()
        var minutes = Math.floor(milliseconds / 60000)
        var maximumSlotMinutes = 0

        if (calendarViewType === 'timeGridDay') maximumSlotMinutes = 30
        else maximumSlotMinutes = 1440

        if (minutes > maximumSlotMinutes) {
          timelineCalendar.unselect()
          $('#newEventMultipleTimeSelect').modal()
        } else {
          // check for time conflicts
          var events = timelineCalendar.getEvents()
          var hasConflict = events.some(function (event) {
            if (!event.start || !event.end) return false
            return hasOverlap(event.start.getTime(), info.start.getTime(), event.end.getTime(), info.end.getTime())
          })

          if (hasConflict) {
            // show conflict error dialog
            $('#newEventTimeConflict').modal()
            return
          }

          $.getScript('/sessions/new', function() {
            // set modal content
            setCreateEventModalContent({
              startTime: moment(info.start).format('hh:mm A'),
              endTime: moment(info.end).format('hh:mm A'),
              setDate: moment(info.start).format('D MMM YYYY')
            })

            globalStartTime = moment(info.start).format('hh:mm A')
            globalEndTime = moment(info.end).format('hh:mm A')
            globalDate = moment(info.start).format('D MMM YYYY')

            $('#newEventDialog form').submit(function() {
              $('.start_hidden').val(globalDate + ' '+ globalStartTime);
              $('.end_hidden').val(globalDate + ' '+ globalEndTime);
              return true
            })

            // show modal
            $('#newEventDialog').removeClass('edit-view').modal()

            // add listeners
            $('#newEventAddDetailsBtn').on('click', function () {
				    	showNewEventDetailsTextArea()
					  })

					  $('#newEventMoreOptionBtn').on('click', function () {
					    $('#newEventMoreOptionDialog').modal()

					    // set input values
					    setCreateEventModalMoreOptionContent({
					      startTime: $('#newEventStartTimepicker').val(),
					      endTime: $('#newEventEndTimepicker').val(),
					      setDate: $('#newEventDatePicker').val(),
					      title: $('#booking_title').val(),
					      description: $('#newEventAddDetailsTextArea').val()
					    })
					  })

					  // initiate timepicker
					  $('.new-event-time-picker').mdtimepicker()

            $('#newEventStartTimepicker').mdtimepicker().on('timechanged', function(e){
                globalStartTime = e.value
                // $('.start_hidden').val(moment(info.start).format('D MMM YYYY') +' '+e.value);
            });

            $('#newEventEndTimepicker').mdtimepicker().on('timechanged', function(e){
                globalEndTime = e.value
                // $('.end_hidden').val(moment(info.start).format('D MMM YYYY') +' '+e.value);
            });
					  // initiate date picker
					  $('.new-event-date-picker').bootstrapMaterialDatePicker({
					    weekStart: 0,
					    time: false,
					    format: 'D MMM YYYY'
					  })
            $('.new-event-date-picker').change(function (e) {
              globalDate = e.target.value
              // info.start = $('.new-event-date-picker').val()
            });

          })

        }
      },
      events: function(info, successCallback, failureCallback) {
        // show loading
        $('.gooey-wrap').removeClass('d-none')

        var onError = function onError (err) {
          $('.gooey-wrap').addClass('d-none')
          failureCallback(err)
        }

        var onSuccess = function onSuccess(data) {
          $('.gooey-wrap').addClass('d-none')
          successCallback(data)
        }

        if(currentUserCheckBoxValue && otherUserCheckBoxValue)
        {
          $.ajax({
              url: "/bookings.json"+window.location.search+"&self=1&other=1",
              dataType: 'JSON',
              success: onSuccess,
              error: onError
            });

        }
        else if(!currentUserCheckBoxValue && otherUserCheckBoxValue)
        {
          $.ajax({
              url: "/bookings.json"+window.location.search+"&self=1&other=0",
              dataType: 'JSON',
              success: onSuccess,
              error: onError
            });

        }
        else if(currentUserCheckBoxValue && !otherUserCheckBoxValue)
        {
          $.ajax({
              url: "/bookings.json"+window.location.search+"&self=0&other=1",
              dataType: 'JSON',
              success: onSuccess,
              error: onError
            });

        }
        else
        {
          $.ajax({
              url: "/bookings.json"+window.location.search+"&self=0&other=0",
              dataType: 'JSON',
              success: onSuccess,
              error: onError
            });
        }
      },
      eventRender: function (info) {
        var description = info.event.extendedProps.eventDescription
        var eventName = info.event.extendedProps.eventName
        var hasStar = info.event.extendedProps.hasStar

        if (description) {
          var descriptionEl = document.createElement('div')
          descriptionEl.innerText = description
          descriptionEl.classList.add('fc-event-description')
          info.el.append(descriptionEl)
        }
        if (eventName) {
          var eventNameEl = document.createElement('div')
          eventNameEl.innerText = eventName
          eventNameEl.classList.add('fc-event-name')
          info.el.append(eventNameEl)
        }
        if (hasStar) {
          var eventStarEl = document.createElement('i')
          eventStarEl.innerText = 'star'
          eventStarEl.classList.add('fc-event-star')
          eventStarEl.classList.add('material-icons')
          info.el.append(eventStarEl)
        }
      }
    }, config)
  }

  function refreshEvents(argument) {
    timelineCalendar.refetchEvents()
    timelineCalendarMoreOptions.refetchEvents()
  }
})
;
