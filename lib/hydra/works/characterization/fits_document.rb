require 'om'

module Hydra::Works::Characterization
  class FitsDocument
    include OM::XML::Document

    set_terminology do |t|
      t.root(path: 'fits',
             xmlns: 'http://hul.harvard.edu/ois/xml/ns/fits/fits_output',
             schema: 'http://hul.harvard.edu/ois/xml/xsd/fits/fits_output.xsd')
      t.fits_v(path: { attribute: 'version' })
      t.identification do
        t.identity do
          t.format_label(path: { attribute: 'format' })
          t.mime_type(path: { attribute: 'mimetype' })
          t.tool(attributes: { toolname: "Exiftool" }) do
            t.exif_tool_version(path: { attribute: 'toolversion' })
          end
        end
      end
      t.fileinfo do
        t.file_size(path: 'size')
        t.last_modified(path: 'lastmodified', attributes: { toolname: "Exiftool" })
        t.filename(path: 'filename')
        t.original_checksum(path: 'md5checksum')
        t.date_created(path: 'created', attributes: { toolname: "Exiftool" })
        t.rights_basis(path: 'rightsBasis')
        t.copyright_basis(path: 'copyrightBasis')
        t.copyright_note(path: 'copyrightNote')
      end
      t.filestatus do
        t.well_formed(path: 'well-formed')
        t.valid(path: 'valid')
        t.status_message(path: 'message')
      end
      t.metadata do
        t.document do
          t.file_title(path: 'title')
          t.file_author(path: 'author')
          t.file_language(path: 'language')
          t.page_count(path: 'pageCount')
          t.word_count(path: 'wordCount')
          t.character_count(path: 'characterCount')
          t.paragraph_count(path: 'paragraphCount')
          t.line_count(path: 'lineCount')
          t.table_count(path: 'tableCount')
          t.graphics_count(path: 'graphicsCount')
        end
        t.dicom do
          t.modality(path: 'modality')
          t.spacing_between_slices(path: 'spacingBetweenSlices')
          t.secondary_capture_device_manufacturer(path: 'secondaryCaptureDeviceManufacturer')
          t.secondary_capture_device_software_vers(path: 'secondaryCaptureDeviceSoftwareVers')
          t.file_type_extension(path: 'fileTypeExtension')
          t.file_meta_info_group_length(path: 'fileMetaInfoGroupLength')
          t.file_meta_info_version(path: 'fileMetaInfoVersion')
          t.media_storage_sop_class_uid(path: 'mediaStorageSOPClassUID')
          t.media_storage_sop_instance_uid(path: 'mediaStorageSOPInstanceUID')
          t.transfer_syntax_uid(path: 'transferSyntaxUID')
          t.implementation_class_uid(path: 'implementationClassUID')
          t.implementation_version_name(path: 'implementationVersionName')
          t.specific_character_set(path: 'specificCharacterSet')
          t.image_type(path: 'imageType')
          t.sop_class_uid(path: 'SOPClassUID')
          t.sop_instance_uid(path: 'SOPInstanceUID')
          t.study_date(path: 'studyDate')
          t.series_date(path: 'seriesDate')
          t.content_date(path: 'contentDate')
          t.study_time(path: 'studyTime')
          t.series_time(path: 'seriesTime')
          t.content_time(path: 'contentTime')
          t.accession_number(path: 'accessionNumber')
          t.conversion_type(path: 'conversionType')
          t.referring_physician_name(path: 'referringPhysicianName')
          t.study_description(path: 'studyDescription')
          t.series_description(path: 'seriesDescription')
          t.patient_name(path: 'patientName')
          t.patient_id(path: 'patientID')
          t.patient_birth_date(path: 'patientBirthDate')
          t.study_instance_uid(path: 'studyInstanceUID')
          t.series_instance_uid(path: 'seriesInstanceUID')
          t.instance_number(path: 'instanceNumber')
          t.image_position_patient(path: 'imagePositionPatient')
          t.image_orientation_patient(path: 'imageOrientationPatient')
          t.samples_per_pixel(path: 'samplesPerPixel')
          t.photometric_interpretation(path: 'photometricInterpretation')
          t.dcm_rows(path: 'rows')
          t.dcm_columns(path: 'columns')
          t.pixel_spacing(path: 'pixelSpacing')
          t.bits_allocated(path: 'bitsAllocated')
          t.bits_stored(path: 'bitsStored')
          t.high_bit(path: 'highBit')
          t.pixel_representation(path: 'pixelRepresentation')
          t.window_center(path: 'windowCenter')
          t.window_width(path: 'windowWidth')
          t.rescale_intercept(path: 'rescaleIntercept')
          t.rescale_slope(path: 'rescaleSlope')
          t.window_center_and_width_explanation(path: 'windowCenterAndWidthExplanation')
          t.pixel_data(path: 'pixelData')
        end
        t.image do
          t.byte_order(path: 'byteOrder')
          t.compression(path: 'compressionScheme')
          t.width(path: 'imageWidth')
          t.height(path: 'imageHeight')
          t.color_space(path: 'colorSpace')
          t.profile_name(path: 'iccProfileName')
          t.profile_version(path: 'iccProfileVersion')
          t.orientation(path: 'orientation')
          t.color_map(path: 'colorMap')
          t.image_producer(path: 'imageProducer')
          t.capture_device(path: 'captureDevice')
          t.scanning_software(path: 'scanningSoftwareName')
          t.exif_version(path: 'exifVersion', attributes: { toolname: "Exiftool" })
          t.gps_timestamp(path: 'gpsTimeStamp')
          t.latitude(path: 'gpsDestLatitude')
          t.longitude(path: 'gpsDestLongitude')
          t.bits_per_sample(path: 'bitsPerSample')
        end
        t.text do
          t.character_set(path: 'charset')
          t.markup_basis(path: 'markupBasis')
          t.markup_language(path: 'markupLanguage')
        end
        t.audio do
          t.duration(path: 'duration')
          t.bit_depth(path: 'bitDepth')
          t.bit_rate(path: 'bitRate')
          t.sample_rate(path: 'sampleRate')
          t.channels(path: 'channels')
          t.data_format(path: 'dataFormatType')
          t.offset(path: 'offset')
        end
        t.video do
          t.width(path: 'imageWidth') # for fits_0.8.5
          t.height(path: 'imageHeight') # for fits_0.8.5
          t.duration(path: 'duration')
          t.bit_rate(path: 'bitRate') # for fits_1.2.0
          t.sample_rate(path: 'sampleRate') # for fits_0.8.5
          t.audio_sample_rate(path: 'audioSampleRate') # for fits_0.8.5
          t.frame_rate(path: 'frameRate') # for fits_0.8.5
          t.track(path: 'track', attributes: { type: 'video' }) do # for fits_1.2.0
            t.width(path: 'width')
            t.height(path: 'height')
            t.aspect_ratio(path: 'aspectRatio')
            t.frame_rate(path: 'frameRate')
          end
        end
      end
      # fits_version needs a different name than it's target node since they're at the same level
      t.fits_version(proxy: [:fits, :fits_v])
      t.format_label(proxy: [:identification, :identity, :format_label])
      # Can't use .mime_type because it's already defined for this dcoument so method missing won't work.
      t.file_mime_type(proxy: [:identification, :identity, :mime_type])
      t.exif_tool_version(proxy: [:identification, :identity, :tool, :exif_tool_version])
      t.file_size(proxy: [:fileinfo, :file_size])
      t.date_modified(proxy: [:fileinfo, :last_modified])
      t.filename(proxy: [:fileinfo, :filename])
      t.original_checksum(proxy: [:fileinfo, :original_checksum])
      t.date_created(proxy: [:fileinfo, :date_created])
      t.rights_basis(proxy: [:fileinfo, :rights_basis])
      t.copyright_basis(proxy: [:fileinfo, :copyright_basis])
      t.copyright_note(proxy: [:fileinfo, :copyright_note])
      t.well_formed(proxy: [:filestatus, :well_formed])
      t.valid(proxy: [:filestatus, :valid])
      t.filestatus_message(proxy: [:filestatus, :status_message])
      t.file_title(proxy: [:metadata, :document, :file_title])
      t.file_author(proxy: [:metadata, :document, :file_author])
      t.page_count(proxy: [:metadata, :document, :page_count])
      t.file_language(proxy: [:metadata, :document, :file_language])
      t.word_count(proxy: [:metadata, :document, :word_count])
      t.character_count(proxy: [:metadata, :document, :character_count])
      t.paragraph_count(proxy: [:metadata, :document, :paragraph_count])
      t.line_count(proxy: [:metadata, :document, :line_count])
      t.table_count(proxy: [:metadata, :document, :table_count])
      t.graphics_count(proxy: [:metadata, :document, :graphics_count])
      t.byte_order(proxy: [:metadata, :image, :byte_order])
      t.bits_per_sample(proxy: [:metadata, :image, :bits_per_sample])
      t.compression(proxy: [:metadata, :image, :compression])
      t.width(proxy: [:metadata, :image, :width])
      t.video_width(proxy: [:metadata, :video, :width])
      t.video_track_width(proxy: [:metadata, :video, :track, :width])
      t.height(proxy: [:metadata, :image, :height])
      t.video_height(proxy: [:metadata, :video, :height])
      t.video_track_height(proxy: [:metadata, :video, :track, :height])
      t.color_space(proxy: [:metadata, :image, :color_space])
      t.profile_name(proxy: [:metadata, :image, :profile_name])
      t.profile_version(proxy: [:metadata, :image, :profile_version])
      t.orientation(proxy: [:metadata, :image, :orientation])
      t.color_map(proxy: [:metadata, :image, :color_map])
      t.image_producer(proxy: [:metadata, :image, :image_producer])
      t.capture_device(proxy: [:metadata, :image, :capture_device])
      t.scanning_software(proxy: [:metadata, :image, :scanning_software])
      t.exif_version(proxy: [:metadata, :image, :exif_version])
      t.gps_timestamp(proxy: [:metadata, :image, :gps_timestamp])
      t.latitude(proxy: [:metadata, :image, :latitude])
      t.longitude(proxy: [:metadata, :image, :longitude])
      t.character_set(proxy: [:metadata, :text, :character_set])
      t.markup_basis(proxy: [:metadata, :text, :markup_basis])
      t.markup_language(proxy: [:metadata, :text, :markup_language])
      t.audio_duration(proxy: [:metadata, :audio, :duration])
      t.video_duration(proxy: [:metadata, :video, :duration])
      t.bit_depth(proxy: [:metadata, :audio, :bit_depth])
      t.audio_sample_rate(proxy: [:metadata, :audio, :sample_rate])
      t.video_sample_rate(proxy: [:metadata, :video, :sample_rate])
      t.video_audio_sample_rate(proxy: [:metadata, :video, :audio_sample_rate])
      t.channels(proxy: [:metadata, :audio, :channels])
      t.data_format(proxy: [:metadata, :audio, :data_format])
      t.offset(proxy: [:metadata, :audio, :offset])
      t.frame_rate(proxy: [:metadata, :video, :frame_rate])
      t.audio_bit_rate(proxy: [:metadata, :audio, :bit_rate])
      t.video_bit_rate(proxy: [:metadata, :video, :bit_rate])
      t.track_frame_rate(proxy: [:metadata, :video, :track, :frame_rate])
      t.aspect_ratio(proxy: [:metadata, :video, :track, :aspect_ratio])
      # dicom specific attributes 
      t.modality(proxy: [:metadata, :dicom, :modality])
      t.spacing_between_slices(proxy: [:metadata, :dicom, :spacing_between_slices])
      t.secondary_capture_device_manufacturer(proxy: [:metadata, :dicom, :secondary_capture_device_manufacturer])
      t.secondary_capture_device_software_vers(proxy: [:metadata, :dicom, :secondary_capture_device_software_vers])
      t.file_type_extension(proxy: [:metadata, :dicom, :file_type_extension])
      t.file_meta_info_group_length(proxy: [:metadata, :dicom, :file_meta_info_group_length])
      t.file_meta_info_version(proxy: [:metadata, :dicom, :file_meta_info_version])
      t.media_storage_sop_class_uid(proxy: [:metadata, :dicom, :media_storage_sop_class_uid])
      t.media_storage_sop_instance_uid(proxy: [:metadata, :dicom, :media_storage_sop_instance_uid])
      t.transfer_syntax_uid(proxy: [:metadata, :dicom, :transfer_syntax_uid])
      t.implementation_class_uid(proxy: [:metadata, :dicom, :implementation_class_uid])
      t.implementation_version_name(proxy: [:metadata, :dicom, :implementation_version_name])
      t.specific_character_set(proxy: [:metadata, :dicom, :specific_character_set])
      t.image_type(proxy: [:metadata, :dicom, :image_type])
      t.sop_class_uid(proxy: [:metadata, :dicom, :sop_class_uid])
      t.sop_instance_uid(proxy: [:metadata, :dicom, :sop_instance_uid])
      t.study_date(proxy: [:metadata, :dicom, :study_date])
      t.series_date(proxy: [:metadata, :dicom, :series_date])
      t.content_date(proxy: [:metadata, :dicom, :content_date])
      t.study_time(proxy: [:metadata, :dicom, :study_time])
      t.series_time(proxy: [:metadata, :dicom, :series_time])
      t.content_time(proxy: [:metadata, :dicom, :content_time])
      t.accession_number(proxy: [:metadata, :dicom, :accession_number])
      t.conversion_type(proxy: [:metadata, :dicom, :conversion_type])
      t.referring_physician_name(proxy: [:metadata, :dicom, :referring_physician_name])
      t.study_description(proxy: [:metadata, :dicom, :study_description])
      t.series_description(proxy: [:metadata, :dicom, :series_description])
      t.patient_name(proxy: [:metadata, :dicom, :patient_name])
      t.patient_id(proxy: [:metadata, :dicom, :patient_id])
      t.patient_birth_date(proxy: [:metadata, :dicom, :patient_birth_date])
      t.study_instance_uid(proxy: [:metadata, :dicom, :study_instance_uid])
      t.series_instance_uid(proxy: [:metadata, :dicom, :series_instance_uid])
      t.instance_number(proxy: [:metadata, :dicom, :instance_number])
      t.image_position_patient(proxy: [:metadata, :dicom, :image_position_patient])
      t.image_orientation_patient(proxy: [:metadata, :dicom, :image_orientation_patient])
      t.samples_per_pixel(proxy: [:metadata, :dicom, :samples_per_pixel])
      t.photometric_interpretation(proxy: [:metadata, :dicom, :photometric_interpretation])
      t.dcm_rows(proxy: [:metadata, :dicom, :dcm_rows])
      t.dcm_columns(proxy: [:metadata, :dicom, :dcm_columns])
      t.pixel_spacing(proxy: [:metadata, :dicom, :pixel_spacing])
      t.bits_allocated(proxy: [:metadata, :dicom, :bits_allocated])
      t.bits_stored(proxy: [:metadata, :dicom, :bits_stored])
      t.high_bit(proxy: [:metadata, :dicom, :high_bit])
      t.pixel_representation(proxy: [:metadata, :dicom, :pixel_representation])
      t.window_center(proxy: [:metadata, :dicom, :window_center])
      t.window_width(proxy: [:metadata, :dicom, :window_width])
      t.rescale_intercept(proxy: [:metadata, :dicom, :rescale_intercept])
      t.rescale_slope(proxy: [:metadata, :dicom, :rescale_slope])
      t.window_center_and_width_explanation(proxy: [:metadata, :dicom, :window_center_and_width_explanation])
      t.pixel_data(proxy: [:metadata, :dicom, :pixel_data])
      
    end

    # Cleanup phase; ugly name to avoid collisions.
    # The send construct here is required to fix up values because the setters
    # are not defined, but rather applied with method_missing.
    def __cleanup__
      # Sometimes, FITS reports the mimetype attribute as a comma-separated string.
      # All terms are arrays and, in this case, there is only one element, so scan the first.
      if file_mime_type.present? && file_mime_type.first.include?(',')
        send("file_mime_type=", [file_mime_type.first.split(',').first])
      end

      # Add any other scrubbers here; don't return any particular value
      nil
    end

    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.fits(xmlns: 'http://hul.harvard.edu/ois/xml/ns/fits/fits_output',
                 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                 'xsi:schemaLocation' => "http://hul.harvard.edu/ois/xml/ns/fits/fits_output
                 http://hul.harvard.edu/ois/xml/xsd/fits/fits_output.xsd",
                 version: '0.6.0', timestamp: '1/25/12 11:04 AM') do
          xml.identification { xml.identity(toolname: 'FITS') }
        end
      end
      builder.doc
    end
  end
end