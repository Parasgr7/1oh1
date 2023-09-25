$(document).ready(function () {
  var debouncedInit = debounce(reservationJsInit, 250)
  var timeSlotTemplate = '<div class="row mx-0 time-slot mb-2"> \
            <div class="col px-0">\
              <button class="btn btn-link ff-ssp time-slot-time fsz-12">7:00am</button>\
            </div>\
            <div class="col pr-0 pl-1 btn-success-wrap">\
              <button class="btn btn-success ff-ssp fsz-12 reservation-continue-btn">Continue</button>\
            </div>\
          </div>'
  var unavailableSlotTemplate = '<h4 class="fsz-12">No slots are available</h4>'

  $(document).on('turbolinks:load', debouncedInit)

  debouncedInit()

  function reservationJsInit () {
  var currentController = $('meta[name=psj]').attr('controller')
  if (currentController !== 'bookings') return

  var selectedDate
  var hasEnoughtCoin

  var offDays = []
  // get initial time slots
  fetchAndUpdateTimeSlots($('#reservation-duration-select').val(), moment().format('YYYY/MM/DD'), $('#timeZoneSelect').val(), true)
  // init calednar
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
	    height: 350,
	    selectable: true,
      unselectAuto: false,
      dayRender: function (dayRenderInfo) {
        var date = moment(dayRenderInfo.date)
        if (date.isBefore(moment().subtract('1', 'day'))) return

        var day = date.format('dddd')
        if (offDays.findIndex(function (a) { return a === day }) !== -1) return
        dayRenderInfo.el.classList.add('valid-date')
        var textElement = dayRenderInfo.el.parentElement.parentElement.parentElement.parentElement.nextElementSibling.querySelector('td[data-date="' + dayRenderInfo.el.attributes['data-date'].value + '"] span')
        textElement.classList.add('valid-date')
        // body...
      },
      dateClick: function (info) {
        var date = moment(info.date)
        if (date.isBefore(moment().subtract('1', 'day')) ||
            offDays.findIndex(function (a) { return a === date.format('dddd') }) !== -1) return

        $('.reservation-calendar .fc-day.selected').removeClass('selected')
        $('.reservation-calendar .fc-day-number.selected').removeClass('selected')

        var date = $(info.dayEl).attr('data-date')

        selectADateInFullCalendar(date)

        personalVeryCustomCalendar.select(date)
      },
	    select: function(info) {
        var start = moment(info.start)
        var end = moment(info.end)
        var day = start.format('dddd')

        if (end.isBefore(moment()) ||
            moment.utc(end.diff(start)).format('D') > 2 ||
            offDays.findIndex(function (a) { return a === day }) !== -1) {
          personalVeryCustomCalendar.unselect()

          if (selectedDate) personalVeryCustomCalendar.select(selectedDate)
        } else {
	      	setSelectedDate(info.start)
          fetchAndUpdateTimeSlots($('#reservation-duration-select').val(), moment(info.start).format('YYYY/MM/DD'), $('#timeZoneSelect').val())

          // select that date
          var dateString = start.format('YYYY-MM-DD')
          selectADateInFullCalendar(dateString)

          // scroll to select time in mobile
          if ($(window).width() < 992) {
            $('.reservation-container').animate({
              scrollTop: 1100
            }, 600)
          }

          return true
	      }

        return false
	   }
	})
  function selectADateInFullCalendar (date) {
    console.log(date)
    $('.reservation-calendar .fc-day.selected').removeClass('selected')
    $('.reservation-calendar .fc-day-number.selected').removeClass('selected')

    var datesElement = $('.reservation-calendar').find('td[data-date="' + date + '"]')

    datesElement.get(0).classList.add('selected')
    $(datesElement.get(1)).find('span').addClass('selected')
  }

	// render calendar

    console.log(personalVeryCustomCalendar)

    setSelectedDate()

    // init scrollbar
    new PerfectScrollbar(document.querySelector('.reservation-container'))
    new PerfectScrollbar(document.querySelector('.reservation-time-slots'))

    // listeners
    $('#reservation-duration-select').change(function (event) {
      var duration = $(this).val()
      var date = selectedDate || personalVeryCustomCalendar.getDate()

      fetchAndUpdateTimeSlots(duration, moment(date).format('YYYY/MM/DD'), $('#timeZoneSelect').val())
    })
    $('#timeZoneSelect').change(function (event) {
      var date = selectedDate || personalVeryCustomCalendar.getDate()
      fetchAndUpdateTimeSlots($('#reservation-duration-select').val(), moment(date).format('YYYY/MM/DD'), $(this).val())
    })

    $('#reservation-prev-month').click(function () {
    	var date = personalVeryCustomCalendar.getDate()

      if (moment(date).isBefore(moment())) return

    	date = moment(date).subtract(1, 'months')

    	personalVeryCustomCalendar.gotoDate(date.format())

    	setSelectedDate()

      // should deactive prev month
      if (moment(date).subtract(1, 'months').isBefore(moment(), 'year') ||
          (moment(date).subtract(1, 'months').isSame(moment(), 'year') &&
          moment(date).subtract(1, 'months').isBefore(moment(), 'month'))) {
        $('#reservation-prev-month').attr('disabled', true)
      }
    })

    $('#reservation-next-month').click(function () {
      $('#reservation-prev-month').attr('disabled', false)

    	var date = personalVeryCustomCalendar.getDate()

    	date = moment(date).add(1, 'months')

    	personalVeryCustomCalendar.gotoDate(date.format())

    	setSelectedDate()
    })

    $('.time-slot .btn-link').click(function () {
    	$('.time-slot').removeClass('active')

    	$(this).parent().parent().addClass('active')
    })
    // methods
    function setSelectedDate (date) {
      selectedDate = date

  		var selectedDatePlaceHolder = document.getElementById('reservation-calendar-selected-date')
  		var selectedDatePlaceHolder2 = document.getElementById('reservation-calendar-selected-date-placeholder-2')

  		if (!selectedDatePlaceHolder || !selectedDatePlaceHolder2) return

  		if (!date) date = personalVeryCustomCalendar.getDate()

  		selectedDatePlaceHolder.innerText = moment(date).format('MMMM YYYY')
  		selectedDatePlaceHolder2.innerText = moment(date).format('dddd, MMMM DD')
    }

    function getTimeSlots (duration, date, profileId, timeZone, clb) {
      $.ajax({
        type: "GET",
        url: '/fetch-time-slots.json?date=' + date + '&slot=' + duration + '&profile=' + profileId + '&time_zone=' + timeZone,
        success (data) {
          offDays = data.off_days
          var selectedDay = moment(date).format('dddd')

          if (offDays.findIndex(function (a) { return a === selectedDay }) !== -1) {
            clb([])
          } else {
            clb(data.slots_distribution)
          }
        }
      })
    }

    function generateTimeSlot (startTime) {
      var element = document.createElement('div')

      element.innerHTML = timeSlotTemplate

      $(element).find('.time-slot-time').text(startTime)
      $(element).find('.reservation-continue-btn').on('click', function (event) {
        event.preventDefault()

        confirmSchedule(startTime)
      })
      return element
    }
    function confirmSchedule (time, clb) {
      if (!hasEnoughtCoin) return

      var guide_id = document.getElementById('reservation_guide_id').value
      var goal = document.getElementById('reservation_goal').value
      var edit = document.getElementById('edit_reservation').value
      var id = document.getElementById('booking_id').value
      var duration = document.getElementById('reservation-duration-select').value
      var date = selectedDate || personalVeryCustomCalendar.getDate()
      var time_zone = document.getElementById('timeZoneSelect').value
      var start_time = time

      $.ajax({
        type: 'POST',
        url: '/session/confirm-schedule.js',
        data: {
          guide_id, goal, duration, start_time, date,time_zone,id,edit
        },
        success (data) {
          if (clb) clb(data)
        }
      })
    }
    function putTimeSlotsInDocument (template) {
      $('.reservation-time-slots').html(template)

      $(template).find('.time-slot .btn-link').click(function () {
        $('.time-slot').removeClass('active')

        $(this).parent().parent().addClass('active')
      })
    }

    function fetchAndUpdateTimeSlots (duration, date, timeZone, isFirstLoad) {
      calculateChest()
      var reservationProfileIdInput = document.getElementById('reservation_profile_id')

      if (!reservationProfileIdInput) return

      var profileId = reservationProfileIdInput.value
      // show loading
      $('#loading').fadeIn()

      getTimeSlots(duration, date, profileId, timeZone, function (data) {
        var templates = data.map(function (times) {
          return generateTimeSlot(moment(times[0]).tz(document.getElementById('timeZoneSelect').value).format('hh:mma'))
        })

        if (!templates.length) templates = unavailableSlotTemplate

        putTimeSlotsInDocument(templates)

        $('#loading').fadeOut()

        if (isFirstLoad) {
          personalVeryCustomCalendar.render()
        }
      })
    }

    function calculateChest () {
      var neededCoin = $('#reservation-duration-select').val() * 10

      $('.reservation-cost').text(neededCoin)

      var chestValue = $('#chest-container').text()

      var remaining = chestValue - neededCoin

      if (remaining < 0) {
        hasEnoughtCoin = false
        $('#remaining-container').addClass('c-red-500 font-weight-bold')
      } else {
        hasEnoughtCoin = true
        $('#remaining-container').removeClass('c-red-500 font-weight-bold')
      }

      $('#remaining-container').text(remaining)
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
