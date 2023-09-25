$(document).on('turbolinks:load', function() {
	var currentController = $('meta[name=psj]').attr('controller')
    if (currentController !== 'categories') return

    // $('#navbar-search').removeClass('d-none-i')

	$(document).on("click", ".category_modal", function () {
		 var category = $(this).data('val');
		 $("#editid").val(category.split('::')[0]) ;
		 $("#editname").val(category.split('::')[1]);
		 $('#edit_category_sample_card .category-card-title').text(category.split('::')[1])
		 $("#editdescription").val(category.split('::')[2]);
		 $('#edit_category_sample_card .category-card-description').text(category.split('::')[2])
		 // $('img#editurl').attr('src', category.split(',')[3]);
		 $('#edit_category_sample_card .category-card-image').attr('style', 'background-image: url("' + category.split('::')[3] +'")')
		 $("#status").val(category.split('::')[4]);
	 });

	$('#report_category_button').click(function (event) {
		event.preventDefault()
		$('#report-dialog').modal()
	})

	$('#add_category_sample_name_input').on('input', function () {
		$('#add_category_sample_card .category-card-title').text($(this).val())
	})
	$('#add_category_sample_description_input').on('input', function () {
		$('#add_category_sample_card .category-card-description').text($(this).val())
	})

	$("#editname").on('input', function () {
		$('#edit_category_sample_card .category-card-title').text($(this).val())
	})

	$("#editdescription").on('input', function () {
		$('#edit_category_sample_card .category-card-description').text($(this).val())
	})

	$("input[type=file].categories").change(function(e){
			var storage = firebase.storage();
			var storageRef = firebase.storage().ref();
			$('#add_category_sample_card .loading').show()
			$('#edit_category_sample_card .loading').show()


			if(e.target.id == "cat_url"){
				$('#loaderCategoryImage').fadeIn();
				$('#loaderCategoryImage').addClass('fa-spin');
					var file=document.getElementById("cat_url").files[0];
					console.log(file);
					var thisref = storageRef.child("category/"+file.name).put(file);

			}
			else if(e.target.id == "edit_url"){
					var file=document.getElementById("edit_url").files[0];
					console.log(file);
					var thisref = storageRef.child("category/"+file.name).put(file);

			}

			thisref.on('state_changed',function(snapshot){
					console.log("File Uploaded Successfully");
			},function (error) {
				$('#add_category_sample_card .loading').hide()
				$('#edit_category_sample_card .loading').hide()
			},function() {
				thisref.snapshot.ref.getDownloadURL().then(function(downloadURL) {
						if(e.target.id=="cat_url")
						{
								profile = document.getElementById("url").value = downloadURL;
								$('#loaderCategoryImage').fadeOut();
								$('#checkCategoryImage').fadeIn();
						}
						else if(e.target.id=="edit_url")
						{
								profile = document.getElementById("edurl").value = downloadURL;
						}

						$('#add_category_sample_card .category-card-image').attr('style', 'background-image: url("' + downloadURL +'")')
						$('#add_category_sample_card .loading').hide()

						$('#edit_category_sample_card .category-card-image').attr('style', 'background-image: url("' + downloadURL +'")')
						$('#edit_category_sample_card .loading').hide()
				})});
	});
})
