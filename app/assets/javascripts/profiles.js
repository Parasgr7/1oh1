// birthday validator extention
$.validator.addMethod("check_date_of_birth", function(value, element) {
    var day = $("#firstPage_day_input").val() || 1;
    var month = $("#firstPage_month_select").val();
    var year = $("#firstPage_year_input").val();
    var age =  13;

    var mydate = new Date();
    mydate.setFullYear(year, month-1, day);

    var currdate = new Date();
    currdate.setFullYear(currdate.getFullYear() - age);

    return currdate >= mydate

}, "You must be at least 13 years of age.")

$.validator.addMethod("check_tags", function(value, element) {
	var tagsParent = $('#' + $(element).attr('tags_parent'))

	if (!tagsParent) return true

	return tagsParent.children().length
}, "You must add at least one language.")

window.addEventListener('popstate', function(event) {
	console.log(event)
	if (!event.state) return
	window.location.reload()
}, false)

$(document).on('turbolinks:load', function() {
		function drawSparklines () {
			function generateData (array) {
				var parsedData = JSON.parse(array).reduce(function (a, b, index) {
					a[index] = b + (index > 0 ? a[index - 1] : 0)
					return a
				}, [])

				console.log('parsedData', parsedData)
				return parsedData.map(function (value, index) {
					var date = moment().add(index, 'days').format()

					return {
						name: "Direct",
						value: value,
						dateUTC: date
					}
				})
			}
			// var sparklineData = {
			//   data: [
			//     {name: "Direct", value: 1, dateUTC: "2011-01-05T00:00:00Z"},
			//     {name: "Direct", value: 2, dateUTC: "2011-01-06T00:00:00Z"},
			//     {name: "Direct", value: 1, dateUTC: "2011-01-07T00:00:00Z"},
			//     {name: "Direct", value: 2, dateUTC: "2011-01-08T00:00:00Z"},
			//     {name: "Direct", value: 1, dateUTC: "2011-01-09T00:00:00Z"},
			//     {name: "Direct", value: 3, dateUTC: "2011-01-10T00:00:00Z"},
			//     {name: "Direct", value: 2.5, dateUTC: "2011-01-11T00:00:00Z"},
			//     {name: "Direct", value: 3, dateUTC: "2011-01-12T00:00:00Z"}
			//   ]
			// };

			var sparklineChart = britecharts.sparkline()
			var sparklineChart2 = britecharts.sparkline()
			var sparklineChart3 = britecharts.sparkline()
			var sparklineChart4 = britecharts.sparkline()

      	// var dataset = sparklineData.data
		var container
		var containerWidth
    	if ($('#sparklinedash').length > 0 && !$('#sparklinedash').children().length) { // guides
      		if (!$('#sparklinedash').attr('data-sparkline')) return
    		container = d3.select('#sparklinedash')
      		containerWidth = container.node() ? container.node().getBoundingClientRect().width : false

      		var dataset = generateData($('#sparklinedash').attr('data-sparkline'))

			sparklineChart
			    .dateLabel('dateUTC')
			    .isAnimated(false)
			    .duration(2500)
			    .height(40)
			    .width(containerWidth)
			    .lineGradient(['#00679F', '#00679F'])
			    .areaGradient(['#E7F1F6', '#FFFFFF'])

			  container.datum(dataset)
			    .call(sparklineChart)

			$('#sparklinedash').find('.area-gradient').attr('x2', 0).attr('y2', 45)
	    }

	    if ($('#sparklinedash2').length > 0 && !$('#sparklinedash2').children().length) { // projects
      		if (!$('#sparklinedash2').attr('data-sparkline')) return
	    	container = d3.select('#sparklinedash2')
      		containerWidth = container.node() ? container.node().getBoundingClientRect().width : false
      		var dataset = generateData($('#sparklinedash2').attr('data-sparkline'))

	      	sparklineChart2
			    .dateLabel('dateUTC')
			    .isAnimated(false)
			    .duration(2500)
			    .height(40)
			    .width(containerWidth)
			    .lineGradient(['#858899', '#858899'])
			    .areaGradient(['#F3F4F5', '#FFFFFF'])

			  container.datum(dataset)
			    .call(sparklineChart2)

			$('#sparklinedash2').find('.area-gradient').attr('x2', 0).attr('y2', 45)
	    }

	    if ($('#sparklinedash3').length > 0 && !$('#sparklinedash3').children().length) { // all
      		if (!$('#sparklinedash3').attr('data-sparkline')) return
	    	container = d3.select('#sparklinedash3')
      		containerWidth = container.node() ? container.node().getBoundingClientRect().width : false

      		var dataset = generateData($('#sparklinedash3').attr('data-sparkline'))

	        sparklineChart3
			    .dateLabel('dateUTC')
			    .isAnimated(false)
			    .duration(2500)
			    .height(40)
			    .width(containerWidth)
			    .lineGradient(['#B33F51', '#B33F51'])
			    .areaGradient(['#F8EDEF', '#FFFFFF'])

			  container.datum(dataset)
			    .call(sparklineChart3)

			$('#sparklinedash3').find('.area-gradient').attr('x2', 0).attr('y2', 45)
	    }

	    if ($('#sparklinedash4').length > 0 && !$('#sparklinedash4').children().length) { // explore
      		if (!$('#sparklinedash4').attr('data-sparkline')) return
	    	 
	    	container = d3.select('#sparklinedash4')
      		containerWidth = container.node() ? container.node().getBoundingClientRect().width : false
      		var dataset = generateData($('#sparklinedash4').attr('data-sparkline'))

	        sparklineChart4
			    .dateLabel('dateUTC')
			    .isAnimated(false)
			    .duration(2500)
			    .height(40)
			    .width(containerWidth)
			    .lineGradient(['#8CC63F', '#8CC63F'])
			    .areaGradient(['#F4F9ED', '#FFFFFF'])

			  container.datum(dataset)
			    .call(sparklineChart4)

			$('#sparklinedash4').find('.area-gradient').attr('x2', 0).attr('y2', 45)
    	}
    };

  drawSparklines();

  $('.search-all-categories-btn').on('click', function () {
  	$("#editExploreModal").animate({ scrollTop: 0 }, 'slow')

  	if ($('#guide-tab').hasClass('active')) $('#edit_guide_tab1 input.filterrific-periodically-observed').focus()
  	else $('#edit_explore_tab1 input.filterrific-periodically-observed').focus()
  })

  $('#memberExplorersEditExploreButton').on('click', function () {
  	$('#editExploreModal').modal()
  	$('#explore-tab').click()
  })

  $('#memberGuidesEditExploreButton').on('click', function () {
  	$('#editExploreModal').modal()
  	$('#guide-tab').click()
  })

  $('#member_explorers_edit_btn').on('click', function (event) {
  	event.preventDefault()
  	$(this).addClass('d-none')

  	$('#member_explorers_save_btn').removeClass('d-none')

  	$('.rateYoMemberExplorers').rateYo('option','readOnly', false)

  	$('#member_explorers_edit_textarea').prop('disabled', false)

  })

  $('#member_guides_edit_btn').on('click', function (event) {
  	event.preventDefault()
  	$(this).addClass('d-none')

  	$('#member_guides_save_btn').removeClass('d-none')

	$(".rateYoMemberGuides").rateYo('option','readOnly', false)

	$('#member_guides_edit_textarea').prop('disabled', false)
  })

	if (window.location.href.includes('about-yourself') && !sessionStorage.getItem('SHOWED_BETA_DIALOG')) {
		$('#beta_modal').modal()
		sessionStorage.setItem('SHOWED_BETA_DIALOG', true)
	} else if (window.location.href.includes('completed') && !sessionStorage.getItem('SHOWED_REWARD_DIALOG')) {
		$('#claimRewardModal').modal({backdrop: 'static', keyboard: false})
		sessionStorage.setItem('SHOWED_REWARD_DIALOG', true)
	}

	$('#editBackgroundPic').click(function(){
		var uploadProfileInput = document.getElementById('profileBackground')
		if(uploadProfileInput){
			uploadProfileInput.click();
		}
	});

	$('#editProfilePic').click(function(){
		var uploadInput = document.getElementById('profilephoto')
		if(uploadInput){
			uploadInput.click();
		}
	});

	$('#profileBackground').change(function (event) {
		$('#editBackgroundPic').addClass('has-loading')

	    var storage = firebase.storage()
	    var storageRef = firebase.storage().ref()

	    var file = event.target.files[0]

	    if (!file) return

	    var thisref = storageRef.child('banner/' + file.name).put(file)

	    thisref.on('state_changed', function (snapshot) {
	        // console.log("File Uploaded Successfully")
	    }, function (error) {
	      $('#editBackgroundPic').removeClass('has-loading')
	    }, function () {
	    	$('#editBackgroundPic').removeClass('has-loading')
	      thisref.snapshot.ref.getDownloadURL().then(function (downloadURL) {
	        event.target.value = ''

	        document.getElementById('urlprofileBackground').value = downloadURL
	        $('#gridBackground').attr('style', 'background-image: url("' + downloadURL +'")')
	      })
	    })
	  })

	$('#edit_explore_create_new_cat_btn').on('click', function () {
		$('#newCategoryModal').modal()
		$('#new_category_modal_type_input').val('Explore')
	})
	$('#edit_guide_create_new_cat_btn').on('click', function () {
		$('#newCategoryModal').modal()
		$('#new_category_modal_type_input').val('Guide')
	})

	$('#profilephoto').change(function (event) {
		$('#editProfilePic').addClass('has-loading')

	    var storage = firebase.storage()
	    var storageRef = firebase.storage().ref()

	    var file = event.target.files[0]

	    if (!file) return

	    var thisref = storageRef.child('profile/' + file.name).put(file)

	    thisref.on('state_changed', function (snapshot) {
	        // console.log("File Uploaded Successfully")
	    }, function (error) {
	      $('#editProfilePic').removeClass('has-loading')
	    }, function () {
	    	$('#editProfilePic').removeClass('has-loading')
	      thisref.snapshot.ref.getDownloadURL().then(function (downloadURL) {
	        event.target.value = ''

	        document.getElementById('urlprofile').value = downloadURL

	        $('#editProfileImg').attr('src', downloadURL)
	      })
	    })
	  })

	var createProjectCollaborators = []
	var createProjectCategories = []
	var editProfileLanguages = window.test || []

	var editProfileLanguagesHiddenElm = document.getElementById('edit-profile-hidden-languages')
	var createProjectCategoriesHiddenElm = document.getElementById('create-project-hidden-categories')
	var createProjectCollaboratorsHiddenElm = document.getElementById('create-project-hidden-collaborators')

	var chipTemplate = '\
    <div class="base-chips d-inline-block">\
      <span class="base-chips-name"></span>\
      <button type="button" class="close">\
        <span aria-hidden="true">&times;</span>\
      </button>\
    </div>\
    '
	$('#img-Profile').click(function (event) {
		$('#profile-pic-ui').toggleClass('d-none')
	})

	var profilePicElm = document.getElementById('profile-pic')

	if (profilePicElm) {
		new Hammer(profilePicElm).on('swipe', function (event) {
			$('#profile-pic-ui').addClass('d-none')
		})
	}

	// add default languages
	editProfileLanguages.forEach(function (language) {
		generateDefaultChipForSelectElement(language, 'language', $('#edit-profile-languages'), editProfileLanguagesHiddenElm, editProfileLanguages)
	})
	// add default createProjectCollaborators
	createProjectCollaborators.forEach(function (colab) {
		generateDefaultChipForSelectElement(colab, 'colab_id', $('#create-project-collaborators'), createProjectCollaboratorsHiddenElm, createProjectCollaborators)
	})

	// add default create project categories
	createProjectCategories.forEach(function (category) {
		generateDefaultChipForSelectElement(category, '_category_id_', $('#create-project-categories'), createProjectCategoriesHiddenElm, createProjectCategories)
	})

	// add
	function generateDefaultChipForSelectElement (value, selectId, wrapper, hiddenInput, storage) {
		if (hiddenInput && storage) {
			hiddenInput.text = JSON.stringify(storage)
		}

		var select = document.getElementById(selectId)

		if (!select) return

	  var selectItem = Array.from(select.options).filter(function (option) {
	    if (value === option.value) return option
	  })
	  var selectText
	  if (selectItem[0]) {
	    selectText = selectItem[0].text
	  }
	  addChips(
	    wrapper,
	    selectText,
	    value,
	    null,
	    removeChipFromArray(storage, hiddenInput)
	  )
	}

  function addChips(wrapper, chipName, chipValue, addClb, removeClb, storage) {
      var element = $(chipTemplate)
      if (storage) {
        if (storage.findIndex(function (item) {
          return item === chipValue
        }) !== -1) return
      }

      element.find('.base-chips-name').text(chipName)
      element.find('button').click(function () {
        removeChips($(this), chipValue, removeClb)
      })

      wrapper.append(element)
      if (addClb) addClb(chipValue)
  }

  function removeChips (chip, chipName, clb) {
    if (clb) clb(chipName)

    chip.parent().remove()
  }

  function addSelectedItemAsChips(wrapper, selectId, addClb, removeClb, storage) {
    var select = document.getElementById(selectId)
    if (!select) return

    var selectText = select.selectedOptions[0].text
    var selectValue = select.selectedOptions[0].value

    addChips(wrapper, selectText, selectValue, addClb, removeClb, storage)
  }

  function storeChipInArray (array, hiddenInput) {
    return function (chipName) {
      array.push(chipName)

      if (hiddenInput) {
        hiddenInput.value = JSON.stringify(array)
      }
    }
  }

  function removeChipFromArray (array, hiddenInput) {
    return function (chipName) {
    	array.splice(array.findIndex(function (item) {
    		return item === chipName
    	}), 1)

      if (hiddenInput) {
        hiddenInput.value = JSON.stringify(array)
      }
    }
  }

	$('#create-project-collaborator-add').click(function () {
		addSelectedItemAsChips(
			$('#create-project-collaborators'),
			'colab_id',
			storeChipInArray(createProjectCollaborators, createProjectCollaboratorsHiddenElm),
			removeChipFromArray(createProjectCollaborators, createProjectCollaboratorsHiddenElm),
			createProjectCollaborators
		)
	})

	$('#create-project-categories-add').click(function () {
		addSelectedItemAsChips(
			$('#create-project-categories'),
			'_category_id_',
			storeChipInArray(createProjectCategories, createProjectCategoriesHiddenElm),
			removeChipFromArray(createProjectCategories, createProjectCategoriesHiddenElm),
			createProjectCategories
		)
	})

	$('#edit-profile-languages-add').click(function () {
		addSelectedItemAsChips(
			$('#edit-profile-languages'),
			'language',
			storeChipInArray(editProfileLanguages, editProfileLanguagesHiddenElm),
			removeChipFromArray(editProfileLanguages, editProfileLanguagesHiddenElm),
			editProfileLanguages
		)
	})

	$('form#update_guide').submit(function () {
		window.sessionStorage.clear()
		return true
	})

	$('form#update_explore').submit(function () {
		window.sessionStorage.clear()
		return true
	})

	$('.tabLink').click(function(event){
	     var tabId = "#tab_" + $(this).attr("id");
	     $('.tabLink').removeClass("selected");
	     $('.tab').removeClass("selected");
	     $(this).addClass("selected");
	     $(tabId).addClass("selected");
	});
	$('#countries').change(function ()
		{
				var input_country = $(this);
				var states_of_country = $("#states-of-country");
				var states_of_country_loading = states_of_country.next()
				var cities_of_state = $("#cities-of-state");

				input_country.prop('disabled', 'disabled')
				states_of_country.prop('disabled', 'disabled')
				states_of_country_loading.show()
				cities_of_state.prop('disabled', 'disabled')

				function onAlways (argument) {
					input_country.prop('disabled', false)
					states_of_country.prop('disabled', false)
					states_of_country_loading.hide()
					cities_of_state.prop('disabled', false)
				}
				$.ajax({
					url: '/states/' + $(this).val(),
					type: 'GET',
					success(data) {
						onAlways()
						states_of_country.empty();
						var opt = '<option value="" selected="" disabled>Select Your State</option>';
						if(Object.keys(data).length == 0){
							var cities_of_state = $("#cities-of-state");
							states_of_country.html('<option value="" selected="">No State found</option>');
							cities_of_state.html('<option value="" selected="">No Cities found</option>');
						} else
						{
							for (var key in data) {
							  opt += '<option value='+ key +'>' + data[key] + '</option>';
								states_of_country.html(opt);
							}
							var cities_of_state = $("#cities-of-state");
							cities_of_state.html('<option value="" selected="" disabled>Select Your State</option>');
						}
					},
					error () {
						onAlways()
					}
				});
		});

		$('#states-of-country').change(function ()
			{
					var input_state = $(this);
					var country = $("#countries");
					var cities_of_state = $("#cities-of-state");
					var cities_of_state_loading = cities_of_state.next()


					input_state.prop('disabled', 'disabled')
					country.prop('disabled', 'disabled')
					cities_of_state.prop('disabled', 'disabled')
					cities_of_state_loading.show()

					function onAlways () {
						input_state.prop('disabled', false)
						country.prop('disabled', false)
						cities_of_state.prop('disabled', false)
						cities_of_state_loading.hide()
					}

					$.ajax({
						url: '/cities/' + $(this).val()+ '/'+ country.val(),
						type: 'GET',
						success(data) {
							onAlways()
							cities_of_state.empty();
							var opt = '<option value="" selected="">Select Your City</option>';
							if(Object.keys(data).length == 0){
								cities_of_state.html('<option value="" selected="">No Cities found</option>');
							} else
							{
								data.forEach(function(i) {
									opt += '<option value="'+ i +'">' + i + '</option>';
									cities_of_state.html(opt);
								});
							}
						},
						error () {
							onAlways()
						}
						});
			});

// initial first time call for guide_categories
	var guideCategories = window.sessionStorage.getItem('guideCategories');
 if(guideCategories){
  guideCategories = JSON.parse(guideCategories);
 }else{
  guideCategories = {guid_categories:[]};
	category_gds = window.guide_ids || []
	category_gds.forEach(id =>{
		guideCategories.guid_categories.push(id);
	  window.sessionStorage.setItem('guideCategories', JSON.stringify(guideCategories));
	})
 }
 guideCategories.guid_categories.forEach(cat=>{
	 id = "guideCat-"+cat
 	$("#" + id).addClass('active')
 });
 setGuideCategories();

 // add Edit Explore on button click
 $('.guide-item-status-button-add').click(function () {
    var parent = $(this).parent().parent()

    var id = Number(parent.attr('id').split('-')[1])

    parent.toggleClass('active')

    if (parent.hasClass('active')) addCategoryG(id)
    else deleteCategoryG(id)

    setGuideCategories()
  })

 	$('.drop-nav .has-more-items').on('click', function (e) {
		$(this).toggleClass('active')
	    e.stopPropagation()
	    e.preventDefault()
	})

 function addCategoryG(category){
  var array = window.sessionStorage.getItem('guideCategories');
  if(array){
   array = JSON.parse(array);
  }else{
   array = {guid_categories:[]};
  }
  array.guid_categories.push(category);
  window.sessionStorage.setItem('guideCategories', JSON.stringify(array));
 }

 function deleteCategoryG(category){
  var array = window.sessionStorage.getItem('guideCategories');
  if(array){
   array = JSON.parse(array);
  }else{
   array = {guid_categories:[]};
  }

  array.guid_categories = array.guid_categories.filter(cat=>{
   return cat!=category;
  });
  window.sessionStorage.setItem('guideCategories', JSON.stringify(array));
 }

 function setGuideCategories(){
  /*this function keeps updating the value of the hidden tag
  to use it anytime in the backend*/
  var array = window.sessionStorage.getItem('guideCategories');
  if(array){
   array = JSON.parse(array);
  }else{
   array = {guid_categories:[]};
  }
  var input = document.getElementById("guideCategories");
  if (input){
  	input.value = JSON.stringify(array);
  }

 }

// initial first time call for explore_categories
 var exploreCategories = window.sessionStorage.getItem('exploreCategories');
 if(exploreCategories){
  exploreCategories = JSON.parse(exploreCategories);
 }else{
  exploreCategories = {exp_categories:[]};
	category_exds = window.explore_ids || []
	category_exds.forEach(id =>{
		exploreCategories.exp_categories.push(id);
	  window.sessionStorage.setItem('exploreCategories', JSON.stringify(exploreCategories));
	})
 }

 exploreCategories.exp_categories.forEach(cat => {
	id = "exploreCat-"+cat
  $("#" + id).addClass('active')
 })

 setExploreCategories();
$('#open_category_modal').click(function () {
	$("#newCategoryModal").modal('show');
})


// add Edit Explore on button click
 $('.explore-item-status-button-add').click(function () {
	 var parent = $(this).parent().parent()
	 var id = Number(parent.attr('id').split('-')[1])

	 parent.toggleClass('active')

	 if (parent.hasClass('active')) addCategory(id)
	 else deleteCategory(id)

	 setExploreCategories()
 })

// profile arrow functions and related methods
 $('.profile-arrow-right-btn').click(function () {
 	var container = $(this).next()
 	var leftPos = container.scrollLeft()

    container.animate({
        scrollLeft: leftPos + 200
    }, 200)
 })

 $('.profile-arrow-left-btn').click(function () {
 	var container = $(this).prev()
 	var leftPos = container.scrollLeft()

    container.animate({
        scrollLeft: leftPos - 200
    }, 200)
 })


$('#block_user_button').click(function () {
	$('#block-dialog').modal()
})
$('#report_user_button').click(function () {
	$('#report-dialog').modal()
})

function hasProfileExploresScroll () {
	var firstScroll = $('#tab1 .profile-x-scroll')
	var secondScroll = $('#tab2 .profile-x-scroll')

	if (firstScroll[0]) {
		if (firstScroll.get(0).scrollWidth > firstScroll.width()) {
			firstScroll.prev().show()
			firstScroll.next().show()
		} else {
			firstScroll.prev().hide()
			firstScroll.next().hide()
		}
	}

	if (secondScroll[0]) {
		if (secondScroll.get(0).scrollWidth > secondScroll.width()) {
			secondScroll.prev().show()
			secondScroll.next().show()
		} else {
			secondScroll.prev().hide()
			secondScroll.next().hide()
		}
	}
}
hasProfileExploresScroll()
$( window ).resize(function() {
	hasProfileExploresScroll()
})

 function addCategory(category){
  var array = window.sessionStorage.getItem('exploreCategories');
  if(array){
   array = JSON.parse(array);
  }else{
   array = {exp_categories:[]};
  }
  array.exp_categories.push(category);
  window.sessionStorage.setItem('exploreCategories', JSON.stringify(array));
 }

 function deleteCategory(category){
  var array = window.sessionStorage.getItem('exploreCategories');
  if(array){
   array = JSON.parse(array);
  }else{
   array = {exp_categories:[]};
  }

  array.exp_categories = array.exp_categories.filter(cat=>{
   return cat!=category;
  });
  window.sessionStorage.setItem('exploreCategories', JSON.stringify(array));
 }

 function setExploreCategories(){
  /*this function keeps updating the value of the hidden tag
  to use it anytime in the backend*/
  var array = window.sessionStorage.getItem('exploreCategories');
  if(array){
   array = JSON.parse(array);
  }else{
   array = {exp_categories:[]};
  }
  var input = document.getElementById("exploreCategories");
  if (input){
  	input.value = JSON.stringify(array);
  }

 }

 $(function () {
	$(".rateYoCustom").each(function(){
		if ( $(this).attr("rating") != null || $(this).attr("rating") != undefined || $(this).attr("rating") != "" ) {
			if ($(this).attr("starsSize") == "normal") {
				$(this).rateYo({
					rating: $(this).attr("rating"),
					ratedFill: "#f1c40f",
					normalFill: "#e4e4e4",
					readOnly: true,
					starWidth: "30px"
				});
			}
			if ($(this).attr("starsSize") == "small") {
				$(this).rateYo({
					rating: $(this).attr("rating"),
					ratedFill: "#f1c40f",
					normalFill: "#e4e4e4",
					readOnly: true,
					starWidth: "20px"
				});
			}
		}
 	});

	$(".rateYoMemberGuides").rateYo({
		rating: $(".rateYoMemberGuides").attr("rating"),
		ratedFill: "#f1c40f",
		normalFill: "#e4e4e4",
		starWidth: "20px",
		readOnly: true,
		onSet: function () {
			var rating = $(".rateYoMemberGuides").rateYo("rating")
			var input = document.getElementById("rateYoMemberGuidesInput");

			if (input) {
				input.value = rating
			}
		}
	});

	$('.rateYoMemberExplorers').rateYo({
		rating: $('.rateYoMemberExplorers').attr("rating"),
		ratedFill: "#f1c40f",
		normalFill: "#e4e4e4",
		starWidth: "20px",
		readOnly: true,
		onSet: function () {
			var rating = $(".rateYoMemberExplorers").rateYo("rating")
			var input = document.getElementById("rateYoMemberExplorerInput");

			if (input) {
				input.value = rating
			}
		}
	});

 	var $rateYo = $(".rateYoInput").rateYo({
 		rating: 3,
 		ratedFill: "#f1c40f",
		normalFill: "#e4e4e4",
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
 		showMoreLessInfo[params.name].showItems = 6;
 		$(params.idShowMore).click(function(){
 			var hiddenItems = showMoreLessInfo[params.name].totalItems - showMoreLessInfo[params.name].showItems;
 			if(hiddenItems > 0){
 				showMoreLessInfo[params.name].showItems = showMoreLessInfo[params.name].showItems + 9;
 			}
 			updateShowItems(params);
		});

		$(params.idShowLess).click(function(){
 			showMoreLessInfo[params.name].showItems = Math.max(6,showMoreLessInfo[params.name].showItems - 9);
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
				if(showMoreLessInfo[params.name].showItems <= 9){
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

 	var paramsExplores = {
 		idMainDiv: "#exploreCategoriesGrid",
 		idMessage: "#exploresProfileMessage",
 		idShowMore:"#moreExploresProfile",
 		idShowLess:"#lessExploresProfile",
 		classItem:".interestsImage",
 		name:"exploresProfile"
 	};
 	showMoreAndLess(paramsExplores);

 	var paramsProfileGuide = {
 		idMainDiv: "#profileGuideMain",
 		idMessage: "#profileGuideMessage",
 		idShowMore:"#moreProfileGuides",
 		idShowLess:"#lessProfileGuides",
 		classItem:".interestsImage",
 		name:"profileGuidesList"
 	};
 	showMoreAndLess(paramsProfileGuide);

 });

})
