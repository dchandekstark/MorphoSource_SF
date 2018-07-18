// Use this script to override jquery file upload options.  Add method can also be defined here
// console.log('in ms_upload');

$( document ).ready(function() {

    // This file is the default initialization of the fileupload.  If you want to call
    // hyraxUploader with other options (like afterSubmit), then override this file.
    Blacklight.onLoad(function() {
      var options = {
          maxNumberOfFiles:10,
          acceptFileTypes: /(\.|\/)(zip|ply|stl|obj|x3d|gltf|png|gif|bmp|dicom|jpg|jpeg|jpeg2000|tiff|tif|mtl|pdf|wmv|mov|avi|mpe?g|m4v)$/i
      };
      $('#fileupload').hyraxUploader(options);
      $('#fileuploadlogo').hyraxUploader({downloadTemplateId: 'logo-template-download'});
    });    

});