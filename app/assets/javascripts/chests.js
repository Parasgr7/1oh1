$(document).ready(function () {
  var debouncedInit = debounce(chestJsInit, 250)

  $(document).on('turbolinks:load', debouncedInit)

  debouncedInit()
  var dynamic_data;
    $.ajax({
             type: "GET",
             url: '/chests.json',
             success(data) {
               dynamic_data = data;
             },
             async:false
     })

   var booking_id = document.getElementById("booking_id").value;
   var peer_user_id = document.getElementById("peer_user_id").value;
   var current_user_id = document.getElementById("current_user_id").value;
   
   function history(val)
   { arr = []
     for(i=1;i<13;i++)
     {
       if(val[i.toFixed(1)])
       {
         arr.push(val[i.toFixed(1)])
       }
       else
       {
         arr.push(0)
       }
     }
     return arr;
   }

  function chestJsInit () {
    var currentController = $('meta[name=psj]').attr('controller')
    if (currentController !== 'chests') return

    if (booking_id.length != 0 && peer_user_id.length != 0 && current_user_id.length != 0) {
      $('#timesUp').modal({
        backdrop: 'static'
      })

      $('#timesUpModalTitle').text('You have ended the session')
    }
    lineChartInit(dynamic_data)
    vectorMapInit(dynamic_data)
  }

  function lineChartInit (data) {
    guides_history = history(data["guides"]);
    explores_history = history(data["explores"]);

    const lineChartBox = document.getElementById('myChart');

    if (lineChartBox) {
      const lineCtx = lineChartBox.getContext('2d');
      lineChartBox.height = 80;

      new Chart(lineCtx, {
        type: 'line',
        data: {
          labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July','August','September','October','November','December'],
          datasets: [{
            label                : 'Guides',
            backgroundColor      : 'rgba(237, 231, 246, 0.5)',
            borderColor          : '#673ab7', // deep-purple-500
            pointBackgroundColor : '#512da8',
            borderWidth          : 2,
            data                 : guides_history,
          }, {
            label                : 'Explores',
            backgroundColor      : 'rgba(232, 245, 233, 0.5)',
            borderColor          : '#4caf50',
            pointBackgroundColor : '#388e3c',
            borderWidth          : 2,
            data                 : explores_history,
          }],
        },

        options: {
          legend: {
            display: false,
          },
        },

      });
    }
  }
  function vectorMapInit (data)  {
    var process_data = {};
    for(i=0;i<data["region_values"].length;i++)
    { x = data["region_values"][i]
      process_data[Object.keys(x)[0]] = x[Object.keys(x)[0]]
    }
    if ($('#world-map-marker').length > 0) {
      // This is a hack, as the .empty() did not do the work
      $('#vmap').remove();

      // we recreate (after removing it) the container div, to reset all the data of the map
      $('#world-map-marker').append(`
        <div
          id="vmap"
          style="
            height: 490px;
            position: relative;
            overflow: hidden;
            background-color: transparent;
          "
        >
        </div>
      `);

      $('#vmap').vectorMap({
        map: 'world_mill',
        backgroundColor: '#fff',
        borderColor: '#fff',
        borderOpacity: 0.25,
        borderWidth: 0,
        color: '#e6e6e6',
        regionStyle : {
          initial : {
            fill : '#e4ecef',
          },
        },

        markerStyle: {
          initial: {
            r: 7,
            'fill': '#fff',
            'fill-opacity':1,
            'stroke': '#000',
            'stroke-width' : 1,
            'stroke-opacity': 0.4,
          },
        },

        markers : data["markers"],
        series: {
          regions: [{
            values: process_data,
            scale: ['#03a9f3', '#02a7f1'],
            normalizeFunction: 'polynomial',
          }],
        },
        hoverOpacity: null,
        normalizeFunction: 'linear',
        zoomOnScroll: false,
        scaleColors: ['#b6d6ff', '#005ace'],
        selectedColor: '#c9dfaf',
        selectedRegions: [],
        enableZoom: false,
        hoverColor: '#fff',
      });
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
