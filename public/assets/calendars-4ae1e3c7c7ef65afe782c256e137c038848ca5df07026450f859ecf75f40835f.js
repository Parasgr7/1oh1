jQuery(document).ready(function($) {
  var calendars = document.querySelectorAll('.personal-timeline-calendar')

  if (!calendars.length) return
	var personalTimelineCalendar = new FullCalendar.Calendar(calendars[0], getTimelineCalendarConfig())
  var timelineCalendarMoreOptions = new FullCalendar.Calendar(calendars[1], getTimelineCalendarConfig({
    contentHeight: 400,
    eventClick: function () {},
    select: function(info) {
      var calendarViewType = personalTimelineCalendar.view.type
      var milliseconds = moment.utc(moment(info.end).diff(moment(info.start))).valueOf()
      var minutes = Math.floor(milliseconds / 60000)
      var maximumSlotMinutes = 0

      if (calendarViewType === 'timeGridDay') maximumSlotMinutes = 30
      else maximumSlotMinutes = 1440

      if (minutes > maximumSlotMinutes) {
        personalTimelineCalendar.unselect()
      } else {
        // check for time conflicts
        var events = personalTimelineCalendar.getEvents()
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
        // $('#newEventStartTimepicker').val(moment(info.start).format('hh:mm A'))
        // $('#newEventEndTimepicker').val(moment(info.end).format('hh:mm A'))
        //
        // $('#newEventDatePicker').val(moment(info.start).format('D MMM YYYY'))
      }
    }
  }))

  personalTimelineCalendar.render()
  timelineCalendarMoreOptions.render()

  window.personalTimelineCalendar = personalTimelineCalendar
  window.timelineCalendarMoreOptions = timelineCalendarMoreOptions

  // very custom calendar
  var personalVeryCustomCalendar = document.querySelector('.personal-very-custom-calendar')
  if (!personalVeryCustomCalendar) return
  var personalVeryCustomCalendar = new FullCalendar.Calendar(personalVeryCustomCalendar, {
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
          personalVeryCustomCalendar.unselect()
        } else {
          personalTimelineCalendar.gotoDate(info.start)
          setCurrentDateTitle(moment(info.start))

          activeSpecificMonth(moment(info.start).format('M'))
        }
     }
  })

  // render calendar
  personalVeryCustomCalendar.render()

  // apply custom scroll bar
  new PerfectScrollbar(document.querySelector('.months-wrap'))
  new PerfectScrollbar(document.querySelector('.fc-scroller'))

  // initiate timepicker
  $('.time-picker').mdtimepicker()

  // initiate date picker
  $('.new-event-date-picker').bootstrapMaterialDatePicker({
    weekStart: 0,
    time: false,
    format: 'D MMM YYYY'
  })
  // initiate checkboxes
  initiateCustomCheckboxes()

  var currentDate = moment(personalVeryCustomCalendar.getDate())
  var prevMonth = currentDate.format('M')

  activeSpecificMonth(prevMonth, true)
  setCurrentDateTitle(currentDate)

  // listeners
  $('.months-wrap .month').on('click', function () {
    var month = $(this).attr('id').replace('month-', '')
    var day = '1'
    var year = currentDate.format('Y')

    // go to specific month
    personalVeryCustomCalendar.gotoDate(moment(month + "-" + day + "-" + year, "MM-DD-YYYY").format())

    activeSpecificMonth(month)
  })

  $('#daily').on('click', function () {
    $(this).parent().find('a').removeClass('active')
    $(this).addClass('active')
    personalTimelineCalendar.changeView('timeGridDay')
  })

  $('#weekly').on('click', function () {
    $(this).parent().find('a').removeClass('active')
    $(this).addClass('active')
    personalTimelineCalendar.changeView('dayGridWeek')
  })

  $('#monthly').on('click', function () {
    $(this).parent().find('a').removeClass('active')
    $(this).addClass('active')
    personalTimelineCalendar.changeView('dayGridMonth')
  })

  $('.recurringAddTimePicker').on('click', function () {
    addTimePicker($(this).parent().parent().find('.time-picker-wrap'))
  })

  $('#more-options-tab2-tab').on('click', function () {
    setTimeout(function () {
      timelineCalendarMoreOptions.updateSize()
    })
  })

  $('#newEventAddDetailsBtn').on('click', function () {
    showNewEventDetailsTextArea()
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

  $('#unavailableDialogBoxRecurrentLink').on('click', function () {
    $('#profileCalendarRecurringUnavailableDialogBox').modal()
  })

  $('#profileCalendarRecurringUnavailableDialogBox').on('hidden.bs.modal', function (e) {
    $('body').removeClass('modal-open')

    setTimeout(function () {
      $('body').removeClass('modal-open')
    }, 1000)
  })

  $('#profileCalendarRecurringUnavailableDialogBox').on('shown.bs.modal', function (e) {
    $('body').addClass('modal-open')

    setTimeout(function () {
      $('body').addClass('modal-open')
    }, 1000)
  })
  $('#newEventMoreOptionBtn').on('click', function () {
    $('#editEventMoreOptionDialog').modal()
    // set input values
    setCreateEventModalMoreOptionContent({
      startTime: $('#newEventStartTimepicker').val(),
      endTime: $('#newEventEndTimepicker').val(),
      setDate: $('#newEventDatePicker').val(),
      title: $('#booking_title').val(),
      description: $('#newEventAddDetailsTextArea').val()
    })
  })

  $('#editEventMoreOptionDialogEditBookingBtn').on('click', function () {
    $('#chagneOrCancelDialog').modal()

    setEditEventModalContent({
      title: $('#newEventSubjectMoreOption').val(),
      startTime: $('#newEventStartTimepickerMoreOption').val(),
      endTime: $('#newEventEndTimepickerMoreOption').val(),
      setDate: $('#newEventDatePickerMoreOption').val(),
      description: $('#newEventAddDetailsTextAreaMoreOption').val()
    })

    setChangeOrCancelDialogContent({
      startTime: $('#newEventStartTimepickerMoreOption').val(),
      endTime: $('#newEventEndTimepickerMoreOption').val(),
      setDate: $('#newEventDatePickerMoreOption').val()
    })
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

        // is event Unavailable
        if (info.event.className === 'unavailable') {
          $.getScript(info.event.extendedProps.unavailable_url, function() {
          })
          return
        }


       $.getScript(info.event.extendedProps.edit_url, function() {

         setEditEventModalContent({
           startTime: moment(info.event.start).format('hh:mm A'),
           endTime: moment(info.event.end).format('hh:mm A'),
           setDate: moment(info.event.start).format('D MMM YYYY'),
           title: info.event.title,
           description: info.event.extendedProps.eventDescription
         })

         $('.start_hidden').val(moment(info.event.start).format('D MMM YYYY') +' '+moment(info.event.start).format('hh:mm A'));
         $('.end_hidden').val(moment(info.event.start).format('D MMM YYYY') +' '+moment(info.event.end).format('hh:mm A'));
         // add listeners
         $('#newEventAddDetailsBtn').on('click', function () {
         	showNewEventDetailsTextArea()
         })
         $('#bookingEditEventEditBookingBtn').on('click', function () {
           $('#chagneOrCancelDialog').modal()

           setChangeOrCancelDialogContent({
            startTime: $('#newEventStartTimepicker').val(),
            endTime: $('#newEventEndTimepicker').val(),
            setDate: $('#newEventDatePicker').val()
           })
         })

         $('#chagneOrCancelDialogChangeReservation').on('click', function () {
          $('#bookingChangeRequestDialog').modal()
          setChangeReservationDialogContent({
            startTime: moment(info.event.start).format('hh:mm A'),
            endTime: moment(info.event.end).format('hh:mm A'),
            setDate: moment(info.event.start).format('D MMM YYYY')
          })
         })

         $('#chagneOrCancelDialogCancelReservationBtn').on('click', function () {
          $('#cancelSessionDialog').modal()
         })

         $('.cancel-session').click(function(){
           if (confirm('Are you sure you want to delete this booking?'))
           {
             $.ajax({
                      type: "DELETE",
                      url: info.event.extendedProps.delete_url,
                      success(data) {
                        return true;
                      }
              })
           }
        })

        $('.edit-booking').click(function(){
            $.ajax({
                     type: "PATCH",
                     url: info.event.extendedProps.delete_url,
                     data: {booking:
                       { title:$('#booking_title').val(),
                         start: $('#newEventDatePicker').val() +' '+$('#newEventStartTimepicker').val(),
                         end: $('#newEventDatePicker').val() +' '+$('#newEventEndTimepicker').val(),
                         description: $('#newEventAddDetailsTextArea').val()
                       }},
                     success(data) {
                       return true;
                     }
             })
       })

         $('#bookingEditEventMoreOptionDialog').on('click', function () {
           $('#editEventMoreOptionDialog').modal()

           // set input values
           setCreateEventModalMoreOptionContent({
             startTime: $('#newEventStartTimepicker').val(),
             endTime: $('#newEventEndTimepicker').val(),
             setDate: $('#newEventDatePicker').val(),
             title: $('#booking_title').val(),
             description: $('#newEventAddDetailsTextArea').val()
           })
         })

         $('#changeSendRequestBackBtn').on('click', function () {
           $('#chagneOrCancelDialog').modal()
         })
         $('#cancelDialogBoxBackBtn').on('click', function () {
           $('#chagneOrCancelDialog').modal()
         })
          // initiate timepicker
         $('.new-event-time-picker').mdtimepicker()
         // initiate date picker
         $('.new-event-date-picker').bootstrapMaterialDatePicker({
           weekStart: 0,
           time: false,
           format: 'D MMM YYYY'
         })
         $('#newEventDialog').addClass('edit-view').modal()
       });
      },
      select: function(info) {
        var events = personalTimelineCalendar.getEvents()
        var hasConflict = events.some(function (event) {
          if (!event.start || !event.end) return false
          return hasOverlap(event.start.getTime(), info.start.getTime(), event.end.getTime(), info.end.getTime())
        })

        if (hasConflict) {
          // show conflict error dialog
          $('#newEventTimeConflict').modal()
          return
        }

        var milliseconds = moment.utc(moment(info.end).diff(moment(info.start))).valueOf()
        var minutes = Math.floor(milliseconds / 60000)

        $('#profileCalendarUnavailableDialogBox').modal()

        setUnavailableDialogContent({
          startTime: moment(info.start).format('hh:mm A'),
          endTime: moment(info.end).format('hh:mm A'),
          setDate: moment(info.start).format('D MMM YYYY')
        })
      },
      events: "/bookings.json?self=1&other=0",
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


  function initiateCustomCheckboxes () {
    var checkboxButtons = $('.checkbox-switcher') // let btn = document.getElementById("btn")
    checkboxButtons.each(function (index, el) {
      el = $(el) // button

      var checkbox = el.find('.checkbox')
      var rect1 = el.find('.rect-1')
      var rect2 = el.find('.rect-2')

      el.mouseup(function () {
        el.toggleClass('h_btn')
        checkbox.toggleClass('h_cb')
        rect1.toggleClass('h_rects')
        rect2.toggleClass('h_rects')

        // find timepicker wrap
        var timePickerWrap = el.parent().parent().parent().find('.time-picker-wrap')

        timePickerWrap.toggleClass('d-none')
        timePickerWrap.next().toggleClass('d-none')

        if (!timePickerWrap.children().length) {
          addTimePicker(timePickerWrap)
        }
      })
    })
  }

  function addTimePicker (el) {
    var template = `
      <div>
        <input type="text" value="" class="time-picker gray-input"/>

        <span class="mx-2">to</span>

        <input type="text" value="" class="time-picker gray-input"/>

        <button type="button" class="d-inline-block btn btn-link btn-link-close" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>`

    var element = document.createElement('div')

    element.innerHTML = template

    $(el).append(element)

    $(el).find('.time-picker').mdtimepicker()

    $(element).find('.btn-link-close').on('click', function () {
      $(this).parent().parent().remove()
    })
  }

  function setUnavailableDialogContent (info) {
    var start = info.startTime
    var end = info.endTime
    var date = info.setDate
    console.log(start)

    $('.today-placeholder').text(date)
    $('.start-time-placeholder').text(start)
    $('.end-time-placeholder').text(end)

    $('.start_hidden').val(moment(date).format('D MMM YYYY') +' '+start);
    $('.end_hidden').val(moment(date).format('D MMM YYYY') +' '+end);

  }

  function setEditEventModalContent (info) {
    var start = info.startTime
    var end = info.endTime
    var date = info.setDate
    var title = info.title
    var description = info.description

    $('#newEventStartTimepicker').val(start)
    $('#newEventEndTimepicker').val(end)
    $('#newEventDatePicker').val(date)
    if (title) $('#booking_title').val(title)
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

    if (title) $('#newEventSubjectMoreOption').val(title)
    if (description) $('#newEventAddDetailsTextAreaMoreOption').val(description)
  }

  function setChangeOrCancelDialogContent (info) {
    var start = info.startTime
    var end = info.endTime
    var date = info.setDate

    $('.start-time-placeholder').text(start)
    $('.end-time-placeholder').text(end)
    $('.today-placeholder').text(date)
  }

  function setChangeReservationDialogContent (info) {
    var start = info.startTime
    var end = info.endTime
    var date = info.setDate

    $('.previous-start-time-placeholder').text(start)
    $('.previous-end-time-placeholder').text(end)
    $('.previous-day-placeholder').text(date)
  }
  function showNewEventDetailsTextArea () {
    $('#newEventAddDetails').removeClass('d-none')
    $('#newEventAddDetailsBtn').addClass('d-none')
  }
  function hideNewEventDetailsTextArea () {
    $('#newEventAddDetails').addClass('d-none')
    $('#newEventAddDetailsBtn').removeClass('d-none')
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
})
;
