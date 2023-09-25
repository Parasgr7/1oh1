$(document).on('turbolinks:load', function() {
  var selectedFilter = "popular"
  var selectedCountry
  var selectedCountryShortForm
  var selectedState
  var selectedCity
  // activate search
  var pathName = window.location.pathname
  var category_name
  var isExplore
  var isGuide
  var isProjects
  var isExploreCategory
  var isGuideCategory
  var isProjectCategory
  var isAllCategory

  var pathInfo = pathName.split('/')
  if (pathInfo[1]== "explores") isExplore = true
  else if (pathInfo[1]== "guides") isGuide = true
  else if (pathInfo[1]== "projects") isProjects = true
  else if (pathInfo[1]== "categories"){
    category_name = pathInfo[2]
    if (pathInfo[3]=="explores") isExploreCategory = true
    else if (pathInfo[3]== "guides") isGuideCategory = true
    else if (pathInfo[3]== "projects") isProjectCategory = true
    else if (pathInfo[3]== undefined)isAllCategory = true
  }

  $('#home-filters .active').removeClass('active')

  // show active item in search bar
  if (isExplore || isExploreCategory) {
    $('#action-explores-filter').addClass('active')
    $('#explores-filters').removeClass('d-none')
    $('#selectBoxFilters').val('explores')
  } else if (isGuide || isGuideCategory) {
    $('#action-guides-filter').addClass('active')
    $('#guides-filters').removeClass('d-none')
    $('#selectBoxFilters').val('guides')
  } else if (isProjects || isProjectCategory) {
    $('#action-projects-filter').addClass('active')
    $('#projects-filters').removeClass('d-none')
    $('#selectBoxFilters').val('projects')
  } else {
    $('#action-all-filter').addClass('active')
    $('#all-filters').removeClass('d-none')
    $('#selectBoxFilters').val('all')
  }

  // show filters
  $('#toggle-filters').on('click', function (event) {
    event.preventDefault()

    var filtersWrap = $('#filters-wrap')

    if (filtersWrap.hasClass('fadeInDown')) {
      $(this).removeClass('active')
      filtersWrap.removeClass('fadeInDown').addClass('fadeOutUp')
    } else {
      $(this).addClass('active')
      filtersWrap.removeClass('fadeOutUp').addClass('fadeInDown')
    }
  })

  $('#selectBoxFilters').on('change', function (event) {
    var href = event.target.options[event.target.selectedIndex].getAttribute('data-href')
    location.replace(href)
  })
  // submit search
  $('#search-form-input').keydown(function (e){
    if(e.keyCode == 13) {
      $('#search-submit-btn').click()
    }
  })

  $('.search-countries').change(function () {
      selectedCountry = $(this).children("option:selected").attr('data-country')
      selectedState = ''
      selectedCity = ''
      // invoke the requestForFilter here , with country & selectedFilter
      // do same for on change of country and rest
      requestForFilter()

      var states_of_country = $(".states-of-country")
      var cities_of_state = $(".cities-of-state")

      if ($(this).val() == "") {
        states_of_country.html("")
      } else {
        selectedCountryShortForm = $(this).val()
        $.ajax({
          url: '/states/' + selectedCountryShortForm,
          type: 'GET',
          success(data) {
            states_of_country.empty()

            var opt = '<option value="" selected="">State</option>'

            if (Object.keys(data).length === 0) {
              states_of_country.html('<option value="" selected="">No State found</option>')
              states_of_country.parent().removeClass('d-none')
              cities_of_state.html('<option value="" selected="">No Cities found</option>')
            } else {
              for (var key in data) {
                opt += '<option value='+ key +' data-state='+data[key]+'>' + data[key] + '</option>'
              }
              states_of_country.html(opt)
              cities_of_state.html('<option value="" selected="">City</option>')
            }
            cities_of_state.parent().addClass('d-none')
            states_of_country.parent().removeClass('d-none')
          }
      })
    }
  })

  $('.states-of-country').change(function () {
    selectedCity = ''
    var input_state = $(this)
    var cities_of_state = $(".cities-of-state")

    if ($(this).val() == "") {
      cities_of_state.html("");
    } else {
      selectedState = $(this).children("option:selected").attr('data-state')
      state = $(this).val()
      requestForFilter()
      $.ajax({
        url: '/cities/' + state + '/'+ selectedCountryShortForm,
        type: 'GET',
        success (data) {
          cities_of_state.empty()
          var opt = '<option value="" selected="">City</option>'
          if (Object.keys(data).length == 0) {
            cities_of_state.html('<option value="" selected="">No Cities found</option>')
          } else {
            data.forEach(function(i) {
              opt += '<option value="'+ i +'" data-state="'+i+'">' + i + '</option>'
            })
            cities_of_state.html(opt)
          }
        }
        })
      }
      cities_of_state.parent().removeClass('d-none')
  })

  $('.cities-of-state').change(function () {
    selectedCity = $(this).val()

    requestForFilter()
  })

  // request for filter
  $('.filters-target button').on("click", function (event) {
    selectedFilter = $(this).attr('data-filter')
    $('.filters-target button.active').removeClass('active')
    $(this).addClass('active')

    requestForFilter()
  })

  $('.removeStateFilter').on('click', function (event) {
    $(this).parent().addClass('d-none')

    selectedState = ''
    requestForFilter()
  })
  $('.removeCityFilter').on('click', function (event) {
    $(this).parent().addClass('d-none')
    selectedCity = ''
    requestForFilter()
  })

  function requestForFilter () {
    // user selection
    // I think you should fire this function when user choosed a city
    var url

    if (isExplore) url = '/explores_filter.js'
    else if (isGuide) url = '/guides_filter.js'
    else if (isProjects) url = '/projects_filter.js'
    else if (isExploreCategory) url = '/categories_explore_filter.js'
    else if (isGuideCategory) url = '/categories_guide_filter.js'
    else if (isProjectCategory) url = '/categories_project_filter.js'
    else if (isAllCategory) url = '/categories_filter.js'
    else url = '/home_filter.js'

    $.ajax({
      type: "GET",
      url: url, // for explores: /explores_filter.js , for guides: /guides_filter.js
      data: {
        filter: selectedFilter,
        country: selectedCountry,
        state: selectedState,
        city: selectedCity,
        category_name: category_name,
      },
      success(data) {
        // console.log(data);
      }
    })
  }


  $input = $('[data-behavior="autocomplete"]');
  var path = $("form #searching-form-input").attr('data-path')
  var sub_option;
  if (path==="/guides")
  {
    sub_option =
    {   //Guides
        listLocation: "guides",
        header: "Guides"
    }
  }
  else if(path=="/explores")
  {
    sub_option =
    {   //Explorers
        listLocation: "explores",
        header: "Explorers"
    }
  }
  else if(path=="/projects")
  {
    sub_option =
    {   //Guides
        listLocation: "projects",
        header: "Projects"
    }
  }
  else{
    sub_option =
    {   //Explorers
        listLocation: "users",
        header: "Users"
    }
  }

  var options = {
    getValue: "name",
    url: function(query){
      return "/search.json?q="+query;
    },
    categories: [
        {   //Categories
            listLocation: "categories",
            header: "Categories"
        },
        sub_option
    ],
    template: {
		type: "custom",
		method: function(value, item) {
        return '<a href="' + item.url + '"><img width="40" height="40" class="mr-2" src="' + item.icon + '"/>' + value + '</a>'
      }
	},
    list: {
      maxNumberOfElements: 12,
      showAnimation: {
        type: "slide", //normal|slide|fade
        time: 400,
        callback: function() {}
      },
      hideAnimation: {
        type: "slide", //normal|slide|fade
        time: 400,
        callback: function() {}
      },
      match: {
			 enabled: true
		  },
      onKeyEnterEvent: function () {
        var searchingForm = document.getElementById('searching-form')
        var submitForm = document.querySelector("[action='/search_result']")

        if (searchingForm) searchingForm.submit()
        else if (submitForm) submitForm.submit()
      },
      onLoadEvent: function () {
        // $input.next().find('ul li > div').first().mouseover()
      }
    }
  };
  $input.easyAutocomplete(options)

$('.explores-review-filter').change(function(event) {
  let url;
  var filter_name = $(this).children("option:selected").val();
  let model = $(this).children("option:selected").attr('data-model')
  let id = $(this).children("option:selected").attr('data-id')
  let tab_name = $(this).children("option:selected").attr('data-tab')

  $.ajax({
    type: "GET",
    url: '/filter_reviews.js',
    data: {
      filter: filter_name,
      model: model,
      id: id,
      tab: tab_name
    },
    success(data) {
      console.log(data);
    }
  })

});

});
