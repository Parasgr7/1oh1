$(document).on('turbolinks:load', function() {
  var loaderId;
  var checkId;
  var inputId;
  var mainTagsList = []
  var supportTagsList = []
  var toolsToolsList = []
  var toolsSupportsList = []
  var projectUploadedImages = []

  $("textarea#project_comment").one("keypress", function () {
    if ($("div#project_comments").length == 0)
    {
      $("#commentingGuideLineDialog").modal("show");
    }
  });

  $("textarea#explore_review").one("keypress", function () {
    if ($("#explorers_tab_explore .explores-review").length == 0)
    {
      $("#commentingGuideLineDialog").modal("show");
    }
  });

  $("textarea#guide_review").one("keypress", function () {
    if ($("#guides_tab_guide .explores-review").length == 0)
    {
      $("#commentingGuideLineDialog").modal("show");
    }
  });

  var projectTagTempalte = '<div class="col-auto pl-0"> \
          <div class="project-tag border c-black fsz-12 px-2 py-1 rounded">\
          <span></span>\
          <button class="btn btn-link centerXY">\
              <i class="material-icons fsz-18 mt-1">close</i>\
            </button>\
          </div> \
        </div>'

  $('.date-picker').bootstrapMaterialDatePicker({
    weekStart: 0,
    time: false,
    format: 'D MMM YYYY'
  })

  $('#update_project_details').validate()
  var update_project_collaborators_validator = $('#update_project_collaborators').validate({
    rules: {
      supportTagsInput: { check_tags: true }
    },
    messages: {
      supportTagsInput: "You must add at least one tag."
    }
  })
  // these function are accessed from ruby js file
  window.projectsGlobalAddProjectMainTag = function (array) {
    mainTagsList.length = 0
    $('#api-main-tags').val('')
    $('.project-main-tags-wrap').html('')

    mainTagsList.push(...array)

    mainTagsList.forEach(function (text) {
      addProjectMainTag(text, true)
    })
  }

  window.projectsGlobalAddSupportTag = function (array) {
    supportTagsList.length = 0
    $('#api-support-tags').val('')
    $('.project-support-tags-wrap').html('')

    supportTagsList.push(...array)

    supportTagsList.forEach(function (text) {
      addProjectSupportTag(text, true)
    })
  }

  window.projectsGlobalAddProjectToolsTools = function (array) {
    toolsToolsList.length = 0
    $('#api-page-tools').val('')
    $('.page-tools-wrap').html('')

    toolsToolsList.push(...array)

    toolsToolsList.forEach(function (text) {
      addProjectToolsTools(text, true)
    })
  }

  window.projectsGlobalAddProjectToolsSupport = function (array) {
    toolsSupportsList.length = 0
    $('#api-page-supplies').val('')
    $('.page-supplies-wrap').html('')

    toolsSupportsList.push(...array)

    toolsSupportsList.forEach(function (text) {
      addProjectToolsSupport(text, true)
    })
  }

  window.projectsGlobalAddProjectImages = function (array) {
    projectUploadedImages.length = 0
    projectUploadedImages.push(...array)

    projectUploadedImages.forEach(function (downloadURL, imageNumber) {
      if (downloadURL) {
        var imageElement = $('.project-upload-photo-btn[data-number="' + imageNumber + '"]').parent()

        addProjectImage(downloadURL, imageElement, imageNumber)
      }
    })
  }

  Array.from(document.querySelectorAll('.scrollable')).forEach(function (element) {
    new PerfectScrollbar(element)
  })

  $('input[type=radio][name=help]').change(function() {
    toggleSupportNeedHelpInput(this.value)
  })

  function toggleSupportNeedHelpInput (value) {
    if (value === 'true') $('#supportNeedHelpWithInput').removeAttr('disabled')
    else if (value === 'false') $('#supportNeedHelpWithInput').attr('disabled', 'disabled')
  }

  toggleSupportNeedHelpInput($('input[type=radio][name=help]:checked').val())

  window.projectsToggleSupportNeedHelpInput = toggleSupportNeedHelpInput

  $('#projectStatusSelect').change(function () {
    var value = $(this).val()

    $('.projectPageMainStatusWrap img').addClass('d-none')

    if (value === 'idea') $('#projectPageMainStatusIdea').removeClass('d-none')
    else if (value === 'inProgress') $('#projectPageMainStatusProgress').removeClass('d-none')
    else $('#projectPageMainStatusCompleted').removeClass('d-none')
  })

  $('#projectMainTags, #projectMainTitle, #projectMainSummary').keydown(function (e) {
    if (e.keyCode === 13) {
      e.preventDefault()
    }
  })

  $('#supportNeedHelpWithInput').keydown(function (e) {
    if (e.keyCode === 13) {
      e.preventDefault()
      // if (!$(this).val()) return

      // addProjectSupportTag($(this).val(), false)
      // $(this).val('')
    }
  })

  $('#project-page-tools-tools').keydown(function (e) {
    if (e.keyCode === 13) {
      e.preventDefault()
      if (!$(this).val()) return

      addProjectToolsTools($(this).val(), false)

      $(this).val('')
    }
  })

  $('#project-page-tools-supplies').keydown(function (e) {
    if (e.keyCode === 13) {
      e.preventDefault()
      if (!$(this).val()) return

      addProjectToolsSupport($(this).val(), false)

      $(this).val('')
    }
  })

  $('#project_edit_main_page_btn').click(function () {
    $('#projectDialogMainPage').modal()
  })

  $('#project_edit_support_btn').click(function () {
    $('#projectDialogSupportPage').modal()
  })

  $('#project_edit_tools_btn').click(function () {
    $('#projectDialogToolsPage').modal()
  })

  $('#prjoectOfferHelpButton').click(function () {
    $('#projectDialogOfferHelp').modal()
  })

  $('#project_delete_btn').click(function () {
    $('#removeProjectDialog').modal()
  })

  $('.project-upload-photo-btn').click(function (event) {
    event.preventDefault()
    var imageNumber = $(this).attr('data-number')

    $('#project-photos-input-file').attr('data-number', imageNumber)
    $('#project-photos-input-file').click()
  })

  $('#project-photos-input-file').change(function (event) {
    var imageNumber = $(this).attr('data-number')
    var imageElement = $('.project-upload-photo-btn[data-number="' + imageNumber + '"]').parent()

    var storage = firebase.storage()
    var storageRef = firebase.storage().ref()

    var file = event.target.files[0]

    if (!file) return

    var thisref = storageRef.child('project/' + file.name).put(file)

    imageElement.addClass('has-loading')

    thisref.on('state_changed', function (snapshot) {
        // console.log("File Uploaded Successfully")
    }, function (error) {
        console.log("Upload Error")
        imageElement.removeClass('has-loading')
    }, function () {
      thisref.snapshot.ref.getDownloadURL().then(function (downloadURL) {
        addProjectImage(downloadURL, imageElement, imageNumber)

        event.target.value = ''
      })
    })
  })
  console.log('find me', update_project_collaborators_validator)
  $('.categories-auto-complete').each(function () {
    var $self = $(this)

    $self.easyAutocomplete({
      url: function (query) {
        return "/categories_name?q=" + query
      },
      getValue: "name",
      list: {
        onChooseEvent () {
          if ($self.attr('id') === 'projectMainTags') {
            addProjectMainTag($self.val(), false)
            $self.val('')
          } else if ($self.attr('id') === 'supportNeedHelpWithInput') {
            addProjectSupportTag($self.val(), false)
          }
        },
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
        }
      },
      requestDelay: 200
    })
  })

  function addProjectImage (downloadURL, imageElement, imageNumber) {
    imageElement.attr('style', 'background-image: url("' + downloadURL +'")')

    imageElement.removeClass('has-loading').addClass('has-image-source')

    projectUploadedImages[imageNumber] = downloadURL

    $('#api-project-uploaded-images').val(projectUploadedImages.filter(function (item) {return !!item}).toString())
  }

  $('.project-remove-photo-btn').click(function (event) {
    event.preventDefault()
    var imageNumber = $(this).attr('data-number')
    var imageElement = $(this).parent()

    imageElement.attr('style', '')

    imageElement.removeClass('has-image-source')

    delete projectUploadedImages[imageNumber]

    $('#api-project-uploaded-images').val(projectUploadedImages.filter(function (item) {return !!item}).toString())
  })

  function addProjectToolsTools (text, force) {
    var index = toolsToolsList.findIndex(function (value) {
      return value === text
    })

    if (index !== -1 && !force) return

    var element = $(projectTagTempalte)
    element.find('.project-tag span').text(text)
    element.find('button').click(function () {
      onRemoveMainTagClick($(this))

      $('#api-page-tools').val(toolsToolsList.toString())
    })

    if (!force) toolsToolsList.push(text)
    $('.page-tools-wrap').append(element)

    $('#api-page-tools').val(toolsToolsList.toString())
  }

  function addProjectToolsSupport (text, force) {
    var index = toolsSupportsList.findIndex(function (value) {
      return value === text
    })

    if (index !== -1 && !force) return

    var element = $(projectTagTempalte)
    element.find('.project-tag span').text(text)
    element.find('button').click(function () {
      onRemoveMainTagClick($(this))

      $('#api-page-supplies').val(toolsSupportsList.toString())
    })

    if (!force) toolsSupportsList.push(text)
    $('.page-supplies-wrap').append(element)

    $('#api-page-supplies').val(toolsSupportsList.toString())
  }


  function addProjectMainTag (text, force) {
    var index = mainTagsList.findIndex(function (value) {
      return value === text
    })

    if (index !== -1 && !force) return

    var element = $(projectTagTempalte)
    element.find('.project-tag span').text(text)
    element.find('button').click(function () {
      onRemoveMainTagClick($(this))

      $('#api-main-tags').val(mainTagsList.toString())
    })

    if (!force) mainTagsList.push(text)
    $('.project-main-tags-wrap').append(element)

    $('#api-main-tags').val(mainTagsList.toString())
  }

  function addProjectSupportTag (text, force) {
    var index = supportTagsList.findIndex(function (value) {
      return value === text
    })

    if (index !== -1 && !force) return

    var element = $(projectTagTempalte)
    element.find('.project-tag span').text(text)
    element.find('button').click(function () {
      onRemoveSupportTagClick($(this))

      $('#api-support-tags').val(supportTagsList.toString())
    })

    if (!force) supportTagsList.push(text)
    $('.project-support-tags-wrap').append(element)

    $('#api-support-tags').val(supportTagsList.toString())
  }

  function onRemoveMainTagClick (element) {
    var text = element.parent().find('span').text()

    element.parent().parent().remove()

    var index = mainTagsList.findIndex(function (value) {
      return value === text
    })

    mainTagsList.splice(index, 1)
  }

  function onRemoveSupportTagClick (element) {
    var text = element.parent().find('span').text()

    element.parent().parent().remove()

    var index = supportTagsList.findIndex(function (value) {
      return value === text
    })

    supportTagsList.splice(index, 1)
  }

  // $("input[type=file]").change(function(e){
  //   var storage = firebase.storage();
  //   var storageRef = firebase.storage().ref();
  //   if(e.target.id == "projectphoto") {
  //     loaderId = '#loaderimage';
  //     checkId = '#check';
  //     inputId = 'url';
  //     $(loaderId).fadeIn();
  //     $(loaderId).addClass('fa-spin');
  //     var file= e.target.files[0];
  //     var thisref = storageRef.child("project/"+file.name).put(file);
  //     $('#' + e.target.id + ' + .custom-file-label').text(file.name);
  //   }else if(e.target.id == "profilephoto") {
  //     loaderId = '#loaderimageprofile';
  //     checkId = '#checkprofile';
  //     inputId = 'urlprofile';
  //     $(loaderId).fadeIn();
  //     $(loaderId).addClass('fa-spin');
  //     var file=document.getElementById("profilephoto").files[0];
  //     var thisref = storageRef.child("profile/"+file.name).put(file);
  //   }else if(e.target.id == "profileBackground") {
  //     loaderId = '#loaderimagebackground';
  //     checkId = '#checkbackground';
  //     inputId = 'urlprofileBackground';
  //     $(loaderId).fadeIn();
  //     $(loaderId).addClass('fa-spin');
  //     var file=document.getElementById("profileBackground").files[0];
  //     var thisref = storageRef.child("banner/"+file.name).put(file);
  //   }else if(e.target.id == "edit_url") {
  //     loaderId = '#loaderedit';
  //     checkId = '#checkedit';
  //     inputId = 'url_edit';
  //     $(loaderId).fadeIn();
  //     $(loaderId).addClass('fa-spin');
  //     var file = e.target.files[0];
  //     var thisref = storageRef.child("category/"+file.name).put(file);
  //     $('#' + e.target.id + ' + .custom-file-label').text(file.name);
  //   }
  //   thisref.on('state_changed',function(snapshot) {
  //       console.log("File Uploaded Successfully");
  //       console.log(snapshot);
  //   },function (error) {
  //       console.log("Upload Error");
  //   },function() {
  //     thisref.snapshot.ref.getDownloadURL().then(function(downloadURL) {
  //       var inputIdComplete = '#' + inputId;
  //       $(inputIdComplete).val(downloadURL);
  //       document.getElementById(inputId).value = downloadURL;
  //       $(loaderId).fadeOut();
  //       $(checkId).fadeIn();
  //       console.log(inputId);
  //       switch (inputId) {
  //         case 'urlprofileBackground':
  //         $('.backgroundimagechange').attr('style','background-image: url(' + downloadURL + ');');
  //         break;
  //         case 'urlprofile':
  //         $('.profileImg').attr('src',downloadURL);
  //         break;
  //         case 'url':
  //         $('.projectPhotoPreview').attr('src',downloadURL);
  //         $('.projectPhotoPreview').css('height','125px');
  //         $('.projectPhotoPreview').css('width','125px');
  //         $('.projectPhotoPreview').css('border','3px solid #e9ecef');
  //         $('.projectPhotoPreview').css('margin-left','25px');
  //         break;
  //         case 'url_edit':
  //         $('.projecteditPhotoPreview').attr('src',downloadURL);
  //         $('.projecteditPhotoPreview').css('height','125px');
  //         $('.projecteditPhotoPreview').css('width','125px');
  //         $('.projecteditPhotoPreview').css('border','3px solid #e9ecef');
  //         $('.projecteditPhotoPreview').css('margin-left','25px');
  //         break;
  //       }
  //     })
  //   });
  // })
});
