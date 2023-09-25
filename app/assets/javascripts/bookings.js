$(document).on('turbolinks:load', function() {
	var bookingCalendar = document.querySelector('.booking-calendar') // .category-calendar
	if (bookingCalendar) {
		var calendars = new FullCalendar.Calendar(bookingCalendar, {
		    plugins: [ 'dayGrid', 'interaction' ],
		    header: {
		      left: 'title',
		      center: '',
		      right: 'prev,next'
		    },
		    showNonCurrentDates: false,
		    aspectRatio: 0.85,
		    columnHeaderFormat: {
				weekday: 'narrow'
		    },
		    dayRender: function (info) {
		      if (Math.round(Math.random() * 10 + 1) % 2 === 0) {
		      	var el = $(info.el)
		        var index = el.index()
		        var tdContent = el.closest('.fc-bg').next().find('td.fc-day-top')[index]

		        $(tdContent).addClass('done')
		      }
		    }
		})

		calendars.render()
	}

	// assign listeners
	// to approve button
	$(document).on("click", ".booking-approve-btn", function(e) {
			$("#approve_booking_id").val($(this).attr("id"));
			var dateInfo = getBookingInfo($(this).attr("id"));
			var classesDateInfo = {
				date:".today-placeholder",
				start_time:".start-time-placeholder",
				end_time:".end-time-placeholder",
				name:".nameCompanionDialog",
				subject:".subjectSessionDialog"
			};
			showBookingInfo(dateInfo, classesDateInfo)
			$('#bookingApproveDialog').modal();
	});

	function getBookingInfo(id){
		var startSelector = "#infoBooking-"+id+" .{_class} time";
		var dateInfo = {
			date:getLabel("date",startSelector),
			start_time:getLabel("start_time",startSelector),
			end_time:getLabel("end_time",startSelector),
			name:$("#nameBooking-"+id).html(),
			subject:$("#categoryBooking-"+id).html()
		};
		console.log(dateInfo);
		function getLabel(classTime,startSelector){
			var selector = (""+startSelector).replace("{_class}",classTime);
			return $(selector).attr("aria-label");
		};
		return dateInfo;
	}

	function showBookingInfo(dateInfo, classesInfo){
		//dateInfo and classesInfo should match keys
		Object.keys(dateInfo).forEach(key=>{
			$(classesInfo[key]).each(function(index){
				$(this).html(dateInfo[key]);
			});
		});
		/*$(classesInfo.date).each(function(index){
			$(this).html(dateInfo.date);
		});
		$(classesInfo.start_time).each(function(index){
			$(this).html(dateInfo.start_time);
		});
		$(classesInfo.end_time).each(function(index){
			$(this).html(dateInfo.end_time);
		});*/
	}
	function runCountDown (argument) {
		$('.countdown-btn').each(function (index, el) {
			var startTime = moment($(el).attr('data-countdown'))
			var defaultText = $(el).text()
			var countdownTime = startTime.toDate()

			$(el).countdown(countdownTime, function(event) {
				var format = '%H:%M:%S'
				var duration = moment.duration(startTime.diff(moment(event.timeStamp)))
				if (duration.asMinutes() < 5) {
					$(el).prop('disabled', false)
					$(el).text(defaultText)
					return
				}

				if (event.offset.totalDays > 0) {
				    format = '%-d day%!d ' + format;
				}
				if (event.offset.weeks > 0) {
				    format = '%-w week%!w ' + format;
				}
				$(el).text(event.strftime(format))
			}).on('finish.countdown', function(event) {
			  $(this).prop('disabled', false)
			  $(this).text(defaultText)
			})
		})
	}
	runCountDown()

	window.runCountDown = runCountDown
	$('.countdown-btn').on('click', function () {
		var navLink = $(this).attr('data-nav-link')

		window.location.replace(navLink)
		// Turbolinks.clearCache()
		// Turbolinks.visit(navLink, { action: 'replace' })
	})

	$(document).on("click", ".booking-decline-btn", function(e) {
			$("#decline_booking_id").val($(this).attr("id"))
			$('#declineBookingDialog').modal()
	});

	$(document).on("click", ".booking-cancel-btn", function(e) {
			$("#cancel_booking_id").val($(this).attr("id"))
			$('#cancelBookingDialog').modal()
	});

	$(document).on("click", ".upcomming-change-or-cancel", function(e) {
			$("#change_booking_id").val($(this).attr("id"))
			$("#cancel_booking_id").val($(this).attr("id"))
			var dateInfo = getBookingInfo($(this).attr("id"));
			var classesDateInfo = {
				date:".today-placeholder",
				start_time:".start-time-placeholder",
				end_time:".end-time-placeholder",
				name:".nameCompanionDialog",
				subject:".subjectSessionDialog"
			};
			showBookingInfo(dateInfo, classesDateInfo);
			$('#chagneOrCancelDialog').modal()
	});

	// on change or cancel dialog box
	$(document).on("click", "#chagneOrCancelDialogChangeReservation", function(e) {
			$('#bookingChangeRequestDialog').modal()
	});

	$(document).on("click", "#chagneOrCancelDialogCancelReservationBtn", function(e) {
			$('#cancelSessionDialog').modal()
	});
	$('#chagneOrCancelDialogChangeReservationBtn').on('click', function () {
    $('#bookingChangeRequestDialog').modal()
   })

	$(document).on("click", ".showTipModal", function(e) {
		$("#send_tip_booking").val($(this).attr("id"))
		$('#sendTipDialog').modal()
	});

	$('#send-tip-options .btn').click(function () {
		$('#send-tip-options .btn').removeClass('active')
		//write code for selecting coins value from #sendTipDialog into a hidden input named "tip_coins"
		$(this).addClass('active')
	})

// block of code for rating the user after sessions
	var $rateYo = $(".rateYoInput").rateYo({
 		rating: 3,
 		ratedFill: "#f1c40f",
		normalFill: "#e4e4e4",
		fullStar: true,
		onSet: function (){
			var rating = $rateYo.rateYo("rating");
			var input = document.getElementById("rateExperience");
		 	if (input) {
		 		input.value = rating;
		 	}
		}
 	});

	//CODE FOR SHOW MORE AND LESS FEATURE
 	if(!showMoreLessInfo){
 		var showMoreLessInfo = {};
 	}

 	function showMoreAndLess(params){
 		showMoreLessInfo[params.name] = {};
 		showMoreLessInfo[params.name].totalItems = $(params.idMainDiv+" "+params.classItem).length;
 		showMoreLessInfo[params.name].showItems = 24;
 		$(params.idShowMore).click(function(){
 			var hiddenItems = showMoreLessInfo[params.name].totalItems - showMoreLessInfo[params.name].showItems;
 			if(hiddenItems > 0){
 				showMoreLessInfo[params.name].showItems = showMoreLessInfo[params.name].showItems + 24;
 			}
 			updateShowItems(params);
		});

		$(params.idShowLess).click(function(){
 			showMoreLessInfo[params.name].showItems = Math.max(24,showMoreLessInfo[params.name].showItems - 24);
			updateShowItems(params);
		});
		updateShowItems(params);
		//function to update which items should be shown
		function updateShowItems(params){
			$(params.idMainDiv+" "+params.classItem).each(function(index){
				if (index + 1 <= showMoreLessInfo[params.name].showItems){
					$(this).show();
				}else{
					$(this).hide();
				}
			});
			var itemsShow = Math.min(showMoreLessInfo[params.name].showItems,showMoreLessInfo[params.name].totalItems);
			$(params.idMessage).html("Showing " + itemsShow + " of " + showMoreLessInfo[params.name].totalItems + " items");
			updateUIMoreLess(params);
		}
		function updateUIMoreLess(params){
			if(showMoreLessInfo[params.name].totalItems==0){
				$(params.idShowMore).css({opacity:0, cursor:"default"});
				$(params.idShowLess).css({opacity:0, cursor:"default"});
				$(params.idMessage).css({opacity:0, cursor:"default"});
			}else{
				$(params.idShowMore).css({opacity:1, cursor:"pointer"});
				$(params.idShowLess).css({opacity:1, cursor:"pointer"});
				$(params.idMessage).css({opacity:1, cursor:"pointer"});
				if(showMoreLessInfo[params.name].showItems <= 24){
					$(params.idShowLess).css({opacity:0, cursor:"default"});
				}

				if(showMoreLessInfo[params.name].showItems >= showMoreLessInfo[params.name].totalItems){
					$(params.idShowMore).css({opacity:0, cursor:"default"});
				}
			}
		}
 	}

 	var params = {
 		idMainDiv: "#projectsListProfile",
 		idMessage: "#projectsProfileMessage",
 		idShowMore:"#showMoreButton",
 		idShowLess:"#showLessButton",
 		classItem:".projectInContainer",
 		name:"projectsProfile"
 	};

 	showMoreAndLess(params);

 	var paramsUpcomingBookings = {
 		idMainDiv: "#mainUpcomingBookings",
 		idMessage: "#upcomingBookingsMessage",
 		idShowMore:"#moreUpcomingBookings",
 		idShowLess:"#lessUpcomingBookings",
 		classItem:".upcomingBookingsItem",
 		name:"upcomingBookingsList"
 	};
 	showMoreAndLess(paramsUpcomingBookings);
 	var paramsPendingBookings = {
 		idMainDiv: "#mainPendingBookings",
 		idMessage: "#pendingBookingsMessage",
 		idShowMore:"#morePendingBookings",
 		idShowLess:"#lessPendingBookings",
 		classItem:".pendingBookingsItem",
 		name:"pendingBookingsList"
 	};
 	showMoreAndLess(paramsPendingBookings);
 	var paramsPreviousBookings = {
 		idMainDiv: "#mainPreviousBookings",
 		idMessage: "#previousBookingsMessage",
 		idShowMore:"#morePreviousBookings",
 		idShowLess:"#lessPreviousBookings",
 		classItem:".previousBookingsItem",
 		name:"previousBookingsList"
 	};
 	showMoreAndLess(paramsPreviousBookings);

	var paramsSubmittedBookings = {
		idMainDiv: "#mainSubmittedBookings",
		idMessage: "#submittedBookingsMessage",
		idShowMore:"#moreSubmittedBookings",
		idShowLess:"#lessSubmittedBookings",
		classItem:".submittedBookingsItem",
		name:"submittedBookingsList"
	};
	showMoreAndLess(paramsSubmittedBookings);

})
