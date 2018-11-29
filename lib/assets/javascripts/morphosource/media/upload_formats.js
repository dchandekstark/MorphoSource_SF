// Takes an array of jquery objects and returns an array of file names.
function file_names(files) {
  file_list = []
  for (var i = 0; i < files.length; i++) {
    file_list.push(files[i].innerText)
  }
  return file_list
}

// Returns an array of file names from the file upload form.
function new_files(){
  return file_names($('#fileupload > table > tbody > tr > td > p > span'));
}

// Returns an array of file names of previously uploaded files.
function old_files(){
  return file_names($('#uploaded_files_list > ul > li'));
}

function regular_expressionize(list) {
  return new RegExp('(\\' + list.replace(/, /g,'|\\') + ')$','i')
}

// Set allowed formats for each Media Type here.
// Returns a formats object.
function media_type_formats(){
  var mediaType = $('#media_media_type').val()
  var mediaTitle = $("#media_media_type option:selected").html().split(' (')[0]
  var acceptedFormatsMessage = "Accepted formats for " + mediaTitle + " files are: "
  var all_formats = ".avi, .bmp, .dcm, .dicom, .gif, .gltf, .jp2, .jpeg, .jpg, .m4v, .mov, .mp4, .mpg, .mpeg, .mtl, .obj, .pdf, .ply, .png, .stl, .tif, .tiff, .wmv, .wrl, .x3d, .zip"
  var formats = {}

  switch (mediaType) {
    case 'Image':
      var list = ".bmp, .dcm, .dicom, .gif, .jp2, .jpeg, .jpg, .png, .tif, .tiff"
      break;
    case 'Video':
      var list = ".avi, .m4v, .mov, .mp4, .mpg, .mpeg, .wmv"
      break;
    case 'CTImageStack':
      var list = ".zip"
      break;
    case 'PhotogrammetryImageStack':
      var list = ".zip"
      break;
    case 'Mesh':
      var list = ".bmp, .dcm, .dicom, .gif, .gltf, .jp2, .jpeg, .jpg, .mtl, .obj, .obj, .ply, .png,. stl, .tif, .tiff, .wrl, .x3d, .zip"
      break;
    case 'Other':
      var list = all_formats
      break;
    case '':
      var list = all_formats
      break;
  }

  if (mediaType == 'Other'){
    formats['message'] = ''
  }
  else if (mediaType == ''){
    formats['message'] = 'Please choose a Media Type under the descriptions tab.'
  }
  else {
    formats['message'] = acceptedFormatsMessage + list;
  }

  formats["list"] = list;
  formats["regex"] = regular_expressionize(list);
  formats['title'] = mediaTitle

  return formats;
}

function setup_matching_format_requirement(){
  // required-files li item
  var requiredFiles = $('#required-files')

  // Create new file format requirement and insert after 'Add files' requirement
  var formatLi = document.createElement('li')
  formatLi.className = "incomplete"
  $(formatLi).attr('id','required-format')
  $(formatLi).text("File formats match selected media type")
  $(formatLi).insertAfter(requiredFiles)

  // Create placeholder for message in the file upload form listing allowed file formats.
  var uploadForm = $('#fileupload')
  var acceptedFormatsMessage = document.createElement('p');
  $(acceptedFormatsMessage).attr('id','formats-message');
  $(acceptedFormatsMessage).text("Uploaded file formats must match the selected media type.")
  // Create placeholder for message in the file upload form listing unallowed files to be removed.
  var unallowedFilesMessage = document.createElement('p');
  $(unallowedFilesMessage).attr('id','files-message');

  var unallowedOldFilesMessage = document.createElement('p');
  $(unallowedOldFilesMessage).attr('id','old-files-message');

  uploadForm.prepend(unallowedOldFilesMessage)
  uploadForm.prepend(unallowedFilesMessage)
  uploadForm.prepend(acceptedFormatsMessage)
}

// Updates message in upload form to display accepted file formats.
function update_accepted_formats_message(){
  var formats = media_type_formats();
  var acceptedFormatsMessage = $('#formats-message');
  acceptedFormatsMessage.text(formats.message);
}

// Updates the file inputs with allowed file extensions, which grays out files with the wrong extension in the popup of user's file system.
// Unfortunately still allows user to drag and drop wrong extensions, or select a folder that contains files with the wrong extensions.
function update_accepted_formats_input(){
  var formats = media_type_formats();
  var fileInput = $('#addfiles > input[type="file"]')
  fileInput.attr("accept", formats.list);
}

// fulfilling or unfulfilling the format requirement triggers Hyrax to check whether the form is valid.
function fulfill_requirement(){
  var requiredFormat = $('#required-format')
  requiredFormat.addClass("complete")
  requiredFormat.removeClass("incomplete")
}

function unfulfill_requirement(){
  var requiredFormat = $('#required-format')
  requiredFormat.addClass("incomplete")
  requiredFormat.removeClass("complete")
}

function check_extensions(files) {
  var formats = media_type_formats();
  var allowedExtensions = formats.regex
  var unallowedFiles = []

  if (!files.length == 0) {
    for (var i = 0; i < files.length; i++) {
      if(!allowedExtensions.exec(files[i])) {
        unallowedFiles.push(files[i])
      }
    }
  }
  return unallowedFiles
}

function media_files() {
  var files = {}

  files.new = new_files();
  files.old = old_files();
  files.all = files.new.concat(files.old)
  files.unallowed_new = check_extensions(new_files());
  files.unallowed_old = check_extensions(old_files());
  files.unallowed_all = files.unallowed_new.concat(files.unallowed_old);

  return files;
}

// Fulfill the formats requirement only if Media Type has been selected, at least one file has been uploaded, and the uploaded files are the correct formats for the selected Media type.
function check_formats_requirement(){
  var files = media_files();
  var mediaType = $('#media_media_type').val();

  if (mediaType == '') {
    unfulfill_requirement();
  }
  else if (!files.unallowed_all.length == 0) {
    unfulfill_requirement();
  }
  else if (files.all.length == 0) {
    unfulfill_requirement();
  }
  else {
    fulfill_requirement();
  }
}

// Updates message in the upload form to display accepted file formats.
function update_unallowed_files_message() {
  var files = media_files();
  var unallowedFilesMessage = $('#files-message');
  var unallowedOldFilesMessage = $('#old-files-message');
  if (files.unallowed_new.length == 0) {
    unallowedFilesMessage.text('');
  }
  if (!files.unallowed_new.length == 0) {
    unallowedFilesMessage.text('Please remove: '+ files.unallowed_new.join(', '));
  }
  if (files.unallowed_old.length == 0) {
    unallowedOldFilesMessage.text('');
  }
  if (!files.unallowed_old.length == 0) {
    unallowedOldFilesMessage.text('The following files were previously uploaded. Please remove them from the Media page before changing the Media type: ' + files.unallowed_old.join(', '));
  }
}

// If a user has uploaded files and then changes the media type, an alert box appears listing the files that are not the right format.
function unallowed_files_alert(){
  var files = media_files();
  var formats = media_type_formats();
  if (!files.unallowed_all.length == 0) {
    alert('Allowed formats for the selected media type are: \n'+formats.list+'\n\n'+'Please remove:\n'+ files.unallowed_all.join(', '));
  }
}

$(document).on('turbolinks:load', function() {
  if ($('form[id*="media"]').length) { // if media form page
    // Adds file formats requirement to the Requirements list
    // Inserts placeholders for allowed formats and uploaded files with the wrong format.
    setup_matching_format_requirement();

    // If editing the form, the formats requirement may have already been fulfilled by previous uploads.
    if (window.location.href.indexOf("/edit?") > -1) {
      check_formats_requirement();
    }

    // Whenever a file is uploaded, check to see if it fulfills the formats requirement, and update the unallowed files message if the file is the wrong extension.
    $('#fileupload').bind('fileuploadcompleted', function(){
      check_formats_requirement();
      update_unallowed_files_message();
    });

    // Whenever a file is deleted, check to see if it fulfills the formats requirement, and update the unallowed files message if the file is the wrong extension.
    $('#fileupload').bind('fileuploaddestroyed', function(){
      check_formats_requirement();
      update_unallowed_files_message();
    });
  }
});

// Whenever the Media Type is changed:
  // Update the accepted formats message on the upload form
  // Update the accepted formats attribute on the file input
  // Check whether the file formats match requirement should be fulfilled
  // Update the upload form with a message listing any unallowed files based on the new media type
  // If there are already files uploaded, and they are incorrect based on the new media type, show an alert listing the allowed formats and any files that are not allowed.
$(document).on('change', '#media_media_type', function() {
  update_accepted_formats_message();
  update_accepted_formats_input();
  check_formats_requirement();
  update_unallowed_files_message();
  unallowed_files_alert();
});
