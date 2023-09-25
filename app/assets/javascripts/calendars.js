$(document).ready(function () {
  var debouncedInit = debounce(calendarsJsInit, 250)

  $(document).on('turbolinks:load', debouncedInit)

  debouncedInit()

  function calendarsJsInit () {
    var balance = 200
    var cancellationFee = 60
    var globalStartTime
    var globalEndTime
    var initialPrice

    var currentController = $('meta[name=psj]').attr('controller')
    if (currentController !== 'calendars') return

    var calendars = document.querySelectorAll('.personal-timeline-calendar')

    if (!calendars.length) return

    if (calendars[0].childElementCount) {
      calendars[0].innerHTML = ''
    }

  	var personalTimelineCalendar = new FullCalendar.Calendar(calendars[0], getTimelineCalendarConfig())

    personalTimelineCalendar.render()

    window.personalTimelineCalendar = personalTimelineCalendar

    // very custom calendar
    var personalVeryCustomCalendar = document.querySelector('.personal-very-custom-calendar')

    if (!personalVeryCustomCalendar) return
    if (personalVeryCustomCalendar.childElementCount) {
      personalVeryCustomCalendar.innerHTML = ''
    }

    var personalVeryCustomCalendar = new FullCalendar.Calendar(personalVeryCustomCalendar, {
        plugins: [ 'dayGrid', 'interaction', 'moment' ],
        header: {
          left: '',
          center: '',
          right: ''
        },
        aspectRatio: 1,
        selectable: true,
        unselectAuto: false,
        height: 'auto',
        select: function(info) {
          if (moment.utc(moment(info.end).diff(moment(info.start))).format('D') > 2) { // disable multi select
            personalVeryCustomCalendar.unselect()
          } else {
            personalTimelineCalendar.gotoDate(info.start)
            setCurrentDateTitle(moment(info.start))
          }
       },
       columnHeaderText: function (date) {
        return moment(date).format('dd').substring(0, 1)
      }
    })

    // render calendar
    personalVeryCustomCalendar.render()

    // apply custom scroll bar
    var ps = new PerfectScrollbar(document.querySelector('.fc-scroller'))

    // initiate timepicker
    $('.time-picker').mdtimepicker()

    // initiate date picker
    $('.new-event-date-picker').bootstrapMaterialDatePicker({
      weekStart: 0,
      time: false,
      format: 'D MMM YYYY'
    })
    // initiate checkboxes
    // initiateCustomCheckboxes()

    var currentDate = moment(personalVeryCustomCalendar.getDate())
    var prevMonth = currentDate.format('M')

    // activeSpecificMonth(prevMonth, true)
    setCurrentDateTitle(currentDate)

    // listeners
    // $('.months-wrap .month').on('click', function () {
    //   var month = $(this).attr('id').replace('month-', '')
    //   var day = '1'
    //   var year = currentDate.format('Y')

    //   // go to specific month
    //   personalVeryCustomCalendar.gotoDate(moment(month + "-" + day + "-" + year, "MM-DD-YYYY").format())

    //   activeSpecificMonth(month)
    // })
    $('#calendarViewSelect').change(function () {
      var viewType = $(this).val()

      switch (viewType) {
        case 'daily':
          personalTimelineCalendar.changeView('timeGridDay')
          $('.day-and-day-number-wrap').show()
          $('.timeline-calendar-border-bottom').addClass('border-bottom')
          break
        case 'weekly':
          personalTimelineCalendar.changeView('dayGridWeek')
          $('.day-and-day-number-wrap').hide()
          $('.timeline-calendar-border-bottom').removeClass('border-bottom')
          break
        case 'monthly':
          personalTimelineCalendar.changeView('dayGridMonth')
          $('.day-and-day-number-wrap').hide()
          $('.timeline-calendar-border-bottom').removeClass('border-bottom')
          break
      }
    })

    $('#calendar-small-calendar-next-month-btn').on('click', function () {
      var date = personalVeryCustomCalendar.getDate()

      date = moment(date).add(1, 'months')

      personalVeryCustomCalendar.gotoDate(date.format())

      setCurrentDateTitle(date)
    })

    $('#calendar-small-calendar-prev-month-btn').on('click', function () {
      var date = personalVeryCustomCalendar.getDate()

      date = moment(date).subtract(1, 'months')

      personalVeryCustomCalendar.gotoDate(date.format())

      setCurrentDateTitle(date)
    })

    $('.calendar-event-types-checkbox').change(function () {
      var checkedValues = $('.calendar-event-types-checkbox:checked').map(function (index, elm) {
        return $(elm).attr('data-type')
      }).toArray()

      console.log(checkedValues) // example ["guide", "pending", "unavailable"]
    })

    $('#newEventAddDetailsBtn').on('click', function () {
      showNewEventDetailsTextArea()
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

    // methods
    // function activeSpecificMonth (currentMonth, scrollToThatMonth) {
    //   document.getElementById('month-' + prevMonth).classList.remove('active')

    //   document.getElementById('month-' + currentMonth).classList.add('active')

    //   prevMonth = currentMonth

    //   if (scrollToThatMonth) {
    //     var activeEl = document.querySelector('.months-wrap .active')
    //     activeEl.scrollIntoView()
    //   }
    // }

    function setCurrentDateTitle (date) {
      var monthEl = document.querySelector('.very-custom-calendar-wrap .calendar-current-date .month-placeholder')
      var dayEl = document.querySelector('.day-placeholder')
      var dayNymEl = document.querySelector('.day-number-placeholder')

      monthEl.innerText = date.format('MMMM YYYY')
      dayEl.innerText = date.format('ddd')
      dayNymEl.innerText = date.format('D')
    }

    function hasOverlap (startDate1, startDate2, endDate1, endDate2) {
      return (startDate1 < endDate2 && startDate2 < endDate1)
    }

    function getTimelineCalendarConfig (config) {
      if (!config) config = {}
      return Object.assign({
        //header: {
          // left: '',
          // center: '',
          // right: ''
        //},
        plugins: [ 'dayGrid', 'timeGrid', 'interaction' ],
        defaultView: 'timeGridDay',
        nowIndicator: true,
        allDaySlot: false,
        contentHeight: 800,
        height: 'auto',
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
          if (info.event.classNames.includes('exploring') || info.event.classNames.includes('guiding')) {
            $.ajax({
                     type: "GET",
                     url: "/get_change_cancel_modal/"+info.event.id+".js",
                     success(data) {
                       return true;
                     }
             })
          }
          else if (info.event.classNames.includes('pending')) {
            $.ajax({
                     type: "GET",
                     url: "/get_approve_modal/"+info.event.id+".js",
                     success(data) {
                       return true;
                     }
             })

          } else if (info.event.classNames.includes('unavailable')) {

          }
          // is event Unavailable
          if (info.event.className === 'unavailable') {
            $.getScript(info.event.extendedProps.unavailable_url, function() {
            })
            return
          }
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
          var timeEl = document.createElement('span')

          timeEl.classList.add('fsz-12', 'font-weight-normal', 'c-light-gray', 'mr-2')

          var start = moment(info.event.start).format('hh:mm A')
          var end = moment(info.event.end).format('hh:mm A')

          timeEl.innerText = start + ' - ' + end

          $(info.el).find('.fc-title').before(timeEl)
        }
      }, config)
    }

    function setUnavailableDialogContent (info) {
      var start = info.startTime
      var end = info.endTime
      var date = info.setDate

      $('.today-placeholder').text(date)
      $('#changeOrCancelTargetDay').val(date)
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

    function setChangeOrCancelDialogContent (info) {
      var start = info.startTime
      var end = info.endTime
      var date = info.setDate

      $('.start-time-placeholder').text(start)
      $('.end-time-placeholder').text(end)
      $('.today-placeholder').text(date)
      $('#changeOrCancelTargetDay').val(date)
    }

    function setChangeReservationDialogContent (info) {
      var start = info.startTime
      var end = info.endTime
      var date = info.setDate

      $('#changeOrCancelDialogStartTime').val(start)
      $('#changeOrCancelDialogEndTime').val(end)
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
    function updateCoinsPlaceHolders (price) {
      if (!price) {
        var milliseconds = moment.utc(moment(globalEndTime, 'hh:mm A').diff(moment(globalStartTime, 'hh:mm A'))).valueOf()
        var minutes = Math.floor(milliseconds / 60000)

        price = minutes * 10
      }

      var remainingBalance = balance - price + initialPrice

      $('.session-cost-placeholder').text(price - initialPrice)
      // in cancelation fee
      $('.new-balance-after-cancellation-placeholder').text(balance + price - cancellationFee)
      $('.new-balance-placeholder-after-time-changed').text(balance + initialPrice - price)

      $('.balancePlaceHolder').text(balance)
      $('.pricePlaceHolder').text(price)
      $('.price-difference-placeholder').text(price - initialPrice)

      if (remainingBalance > 0) {
        $('.remainingCoinPlaceHolder').text(remainingBalance).removeClass('c-red-500')
        $('#bookingEditEventEditBookingBtn').attr('disabled', false)
        $('#changeSendRequestDialogSubmit').attr('disabled', false)
      } else {
        $('.remainingCoinPlaceHolder').text(remainingBalance).addClass('c-red-500')
        $('#bookingEditEventEditBookingBtn').attr('disabled', true)
        $('#changeSendRequestDialogSubmit').attr('disabled', true)
      }
    }
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
