class SubmissionsController < ApplicationController

  load_and_authorize_resource

  before_action :instantiate_work_forms

  def new
byebug
    # clear session when user request to start all over
    if cookies[:ms_submission_start_over].present?
        clear_session_submission_settings
    end
    if session[:submission].present?
      # Continue where the user has left off
      # last_render saves the page that needs to be rendered if the user reload the page, or
      # come back to when the user has left off later
      # saved_step stores the last page usually. it's needed when, for example, the user needs to go back
      # to new device after creating / selecting an institution.
      # if needed, read the var from session instead: session[:submission]['saved_step']
      saved_step = cookies[:saved_step]
      last_render = cookies[:last_render]
      if last_render.present?
        # certain pages require getting back the search result before rendering
        if last_render == 'biospec'
          @docs = search_biospec
        elsif last_render == 'cho'
          @docs = search_cho
        end
        render last_render
      end
    else
      session[:submission] ||= {}
      @submission = Submission.new(session[:submission])
    end
  end

  def create
    reinstantiate_submission
    # todo: is there a need to separate raw and derived flow in two if and else?
    if params['biospec_search'].present?
      @docs = search_biospec
      if @docs.nil? || @docs.empty?
        # if no search result, user might need to go back to initial step
        @submission.saved_step = ""
      else
        @submission.saved_step = "biospec_search"
      end
      store_submission
      render_and_save 'biospec'
    elsif params['biospec_select'].present?
      @submission.saved_step = "biospec_select"
      session[:submission][:biospec_id] = submission_params[:biospec_id]
      store_submission
      render_and_save 'device'
    elsif params['biospec_will_create'].present?
      # possibly need to store other flow data here
      @submission.saved_step = "biospec_will_create"
      store_submission
      render_and_save 'institution'
    elsif params['institution_select'].present? || params['no_institution'].present?
      if params['institution_select'].present?
        session[:submission][:institution_id] = submission_params[:institution_id]
      end
      if @submission.saved_step == "biospec_will_create"
        @submission.saved_step = "biospec_institution_select"
        render_and_save 'taxonomy'
      elsif @submission.saved_step == "device_will_create"
        @submission.saved_step = "device_institution_select"
        render_and_save 'device_create'
      elsif @submission.saved_step == "cho_will_create"
        @submission.saved_step = "cho_institution_select"
        render_and_save 'cho_create'
      else
        # should not end up here
      end
      store_submission
    elsif params['taxonomy_select'].present?
      @submission.saved_step = "biospec_taxonomy_select"
      render_and_save 'biospec_create'
    elsif params['device_select'].present?
      session[:submission][:device_id] = submission_params[:device_id]
      @submission.saved_step = "device_select"
      store_submission
      render_and_save 'image_capture'
    elsif params['device_will_create'].present?
      # possibly need to store other flow data here
      @submission.saved_step = "device_will_create"
      store_submission
      render_and_save 'institution'
    elsif params['parent_media_select'].present?
      session[:submission][:parent_media_list] = submission_params[:parent_media_list]
      store_submission
      render_and_save 'processing_event'
    # This button below is handled by js.  Remove later
    #    elsif params['parent_media_how_to_proceed_continue'].present? 
    #      session[:submission][:parent_media_how_to_proceed] = submission_params[:parent_media_how_to_proceed]
    #      store_submission
    #      render_and_save 'new'
    elsif params['cho_search'].present?
      session[:submission][:cho_search_collection_code] = submission_params[:cho_search_collection_code]
      # todo: add the other 3 search fields here
      @submission.saved_step = "cho_search"
      store_submission
      @docs = search_cho
      render_and_save 'cho'
    elsif params['cho_select'].present?
      session[:submission][:cho_id] = submission_params[:cho_id]
      @submission.saved_step = "cho_select"
      store_submission
      render_and_save 'device'
    elsif params['cho_will_create'].present?
      # possibly need to store other flow data here
      @submission.saved_step = "cho_will_create"
      store_submission
      render_and_save 'institution'
    else
      finish_submission
    end
  end

  def render_and_save(pg)
    # save this page to render again if user reloads the page
    cookies.permanent[:last_render] = pg
    if (pg != 'new')
      cookies.delete :saved_clicks
    end
    render pg
  end

  def stage_biological_specimen
    reinstantiate_submission
    @submission.biospec_id = 'new'
    store_submission
    biospec_model_params = Hyrax::BiologicalSpecimenForm.model_attributes(params[:biological_specimen])
    session[:submission_biospec_create_params] = biospec_model_params
    render_and_save 'device'
  end

  def stage_cho
    reinstantiate_submission
    @submission.cho_id = 'new'
    store_submission
    cho_model_params = Hyrax::CulturalHeritageObjectForm.model_attributes(params[:cultural_heritage_object])
    session[:submission_cho_create_params] = cho_model_params
    render_and_save 'device'
  end

  def stage_device
    reinstantiate_submission
    @submission.device_id = 'new'
    store_submission
    device_model_params = Hyrax::DeviceForm.model_attributes(params[:device])
    session[:submission_device_create_params] = device_model_params
    render_and_save 'image_capture'
  end

  def stage_imaging_event
    reinstantiate_submission
    @submission.imaging_event_id = 'new'
    @submission.saved_step = 'imaging_event_staged'
    store_submission
    imaging_event_model_params = Hyrax::ImagingEventForm.model_attributes(params[:imaging_event])
    session[:submission_imaging_event_create_params] = imaging_event_model_params
    # need to go to proceesing event if coming from Derived media > Parents not in MorphoSource
    # parent_media_how_to_proceed
    if cookies[:will_create].present?
      if cookies[:will_create].include? 'processing_event'
        render_and_save 'processing_event'
      end
    end
    render_and_save 'media'
  end

  def stage_institution
    reinstantiate_submission
    @submission.institution_id = 'new'
    store_submission
    institution_model_params = Hyrax::InstitutionForm.model_attributes(params[:institution])
    session[:submission_institution_create_params] = institution_model_params
    if @submission.saved_step == "device_will_create"
      render_and_save 'device_create'
    elsif @submission.saved_step == "biospec_will_create"
      render_and_save 'taxonomy'
    elsif @submission.saved_step == "cho_will_create"
      render_and_save 'cho_create'
    else
      #should not be here
    end
  end

  def stage_media
    reinstantiate_submission
    @submission.media_id = 'new'
    store_submission
    media_model_params = Hyrax::MediaForm.model_attributes(params[:media])
    media_uploaded_files = params[:uploaded_files]
    session[:submission_media_create_params] = media_model_params
    session[:submission_media_uploaded_files] = media_uploaded_files
    finish_submission
  end

  def stage_processing_event
    reinstantiate_submission
    @submission.processing_event_id = 'new'
    store_submission
    processing_event_model_params = Hyrax::ProcessingEventForm.model_attributes(params[:processing_event])
    session[:submission_processing_event_create_params] = processing_event_model_params
    render_and_save 'media'
  end

  def stage_taxonomy
    reinstantiate_submission
    @submission.taxonomy_id = 'new'
    store_submission
    taxonomy_model_params = Hyrax::TaxonomyForm.model_attributes(params[:taxonomy])
    session[:submission_taxonomy_create_params] = taxonomy_model_params
    render_and_save 'biospec_create'
  end

  def finish_submission
    reinstantiate_submission
    # The various object '_create_params' are defined as instance variables so they are available to the
    # placeholder 'show' page for debugging purposes.  If they are not needed for that, they can become local
    # variables in this method instead.
    @biospec_create_params = session[:submission_biospec_create_params]
    @cho_create_params = session[:submission_cho_create_params]
    @imaging_event_create_params = session[:submission_imaging_event_create_params]
    @institution_create_params = session[:submission_institution_create_params]
    @device_create_params = session[:submission_device_create_params]
    @media_create_params = session[:submission_media_create_params]
    @processing_event_create_params = session[:submission_processing_event_create_params]
    @taxonomy_create_params = session[:submission_taxonomy_create_params]
    media_uploaded_files = session[:submission_media_uploaded_files]
    if @institution_create_params.present?
      @submission.institution_id = create_institution(@institution_create_params)
    end
    if @taxonomy_create_params.present?
      @submission.taxonomy_id = create_taxonomy(@taxonomy_create_params)
    end
    if @biospec_create_params.present?
      @submission.biospec_id = create_biological_specimen(@biospec_create_params)
    end
    if @cho_create_params.present?
      @submission.cho_id = create_cho(@cho_create_params)
    end
    if @device_create_params.present?
      @submission.device_id = create_device(@device_create_params)
    end
    if @imaging_event_create_params.present?
      @submission.imaging_event_id = create_imaging_event(@imaging_event_create_params)
    end
    if @processing_event_create_params.present?
      @submission.processing_event_id = create_processing_event(@processing_event_create_params)
    end
    if @media_create_params.present?
      @submission.media_id = create_media(@media_create_params, media_uploaded_files)
    end
    clear_session_submission_settings
    render 'show'
    #redirect_to '/concern/media/' + @submission.media_id
  end

  def create_biological_specimen(params)
    parent_attributes = {}
    if @submission.institution_id.present?
      parent_attributes.merge!({ '0' => { "id" => @submission.institution_id, "_destroy" => "false" } })
    end
    if @submission.taxonomy_id.present?
      parent_attributes.merge!({ '1' => { "id" => @submission.taxonomy_id, "_destroy" => "false" } })
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(BiologicalSpecimen, params)
  end

  def create_cho(params)
    parent_attributes = {}
    if @submission.institution_id.present?
      parent_attributes.merge!({ '0' => { "id" => @submission.institution_id, "_destroy" => "false" } })
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(CulturalHeritageObject, params)
  end

  def create_device(params)
    create_work(Device, params)
  end

  def create_imaging_event(params)
    parent_attributes = {}
    if @submission.biospec_id.present?
      parent_attributes.merge!({ '0' => { "id" => @submission.biospec_id, "_destroy" => "false" } })
    end
    if @submission.cho_id.present?
      parent_attributes.merge!({ '1' => { "id" => @submission.cho_id, "_destroy" => "false" } })
    end
    if @submission.device_id.present?
      parent_attributes.merge!({ '2' => { "id" => @submission.device_id, "_destroy" => "false" } })
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(ImagingEvent, params)
  end

  def create_processing_event(params)
    parent_attributes = {}
    if @submission.parent_media_list.present?
      idx = 0
      @submission.parent_media_list.split(',').each do |this_id|
        if this_id != ''
          parent_attributes.merge!({ idx.to_s => { "id" => this_id.to_s, "_destroy" => "false" } })
          idx += 1
        end
      end
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(ProcessingEvent, params)
  end

  def create_taxonomy(params)
    create_work(Taxonomy, params)
  end

  def create_institution(params)
    create_work(Institution, params)
  end

  def create_media(params, uploaded_files)
    parent_attributes = {}
    if @submission.imaging_event_id.present?
      parent_attributes.merge!({ '0' => { "id" => @submission.imaging_event_id, "_destroy" => "false" } })
    end
    if @submission.processing_event_id.present?
      parent_attributes.merge!({ '1' => { "id" => @submission.processing_event_id, "_destroy" => "false" } })
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    if uploaded_files.present?
      params.merge!({ uploaded_files: uploaded_files })
    end
    create_work(Media, @media_create_params)
  end

  private

  def clear_session_submission_settings
    session[:submission] = nil
    session[:submission_biospec_create_params] = nil
    session[:submission_cho_create_params] = nil
    session[:submission_device_create_params] = nil
    session[:submission_imaging_event_create_params] = nil
    session[:submission_processing_event_create_params] = nil
    session[:submission_institution_create_params] = nil
    session[:submission_media_create_params] = nil
    session[:submission_taxonomy_create_params] = nil
    cookies.delete :ms_submission_start_over
    cookies.delete :saved_step
    cookies.delete :last_render
    cookies.delete :saved_clicks
    cookies.delete :will_create
  end

  def create_work(model, form_params)
    curation_concern = model.new
    attributes_for_actor = form_params
    unless model == Media
      attributes_for_actor.merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
    end
    env = Hyrax::Actors::Environment.new(curation_concern, current_ability, attributes_for_actor)
    Hyrax::CurationConcern.actor.create(env)
    curation_concern.id
  end

  def instantiate_work_forms
    @biological_specimen_form = Hyrax::WorkFormService.build(BiologicalSpecimen.new, current_ability, self)
    @cho_form = Hyrax::WorkFormService.build(CulturalHeritageObject.new, current_ability, self)
    @device_form = Hyrax::WorkFormService.build(Device.new, current_ability, self)
    @imaging_event_form = Hyrax::WorkFormService.build(ImagingEvent.new, current_ability, self)
    @processing_event_form = Hyrax::WorkFormService.build(ProcessingEvent.new, current_ability, self)
    @institution_form = Hyrax::WorkFormService.build(Institution.new, current_ability, self)
    @media_form = Hyrax::WorkFormService.build(Media.new, current_ability, self)
    @taxonomy_form = Hyrax::WorkFormService.build(Taxonomy.new, current_ability, self)
  end

  def reinstantiate_submission
    session[:submission].deep_merge!(submission_params) if params[:submission]
    @submission = Submission.new(session[:submission])
  end

  def search_biospec
    search_params = {}
    biospec_search_params = submission_params.select{ |k,v| k.match(/^biospec_search_/) }.select{ |k,v| v.present? }
    biospec_search_params.each do |k,v|
      search_params[k.sub('biospec_search_', '')] = v
    end
    Morphosource::PhysicalObjectsSearchService.call(BiologicalSpecimen, search_params)
  end

  def search_cho
    search_params = {}
    cho_search_params = submission_params.select{ |k,v| k.match(/^cho_search_/) }.select{ |k,v| v.present? }
    cho_search_params.each do |k,v|
      search_params[k.sub('cho_search_', '')] = v
    end
    Morphosource::PhysicalObjectsSearchService.call(CulturalHeritageObject, search_params)
  end

  def store_submission
    session[:submission] = { biospec_id: @submission.biospec_id,
                              cho_id: @submission.cho_id,
                              biospec_or_cho: @submission.biospec_or_cho,
                              device_id: @submission.device_id,
                              institution_id: @submission.institution_id,
                              raw_or_derived_media: @submission.raw_or_derived_media,
                              parent_media_how_to_proceed: @submission.parent_media_how_to_proceed,
                              parent_media_list: @submission.parent_media_list,
                              taxonomy_id: @submission.taxonomy_id,
                              cho_search_collection_code: @submission.cho_search_collection_code,
                              saved_step: @submission.saved_step
      }
    if @submission.saved_step.present?
      cookies.permanent[:saved_step] = @submission.saved_step
    end
  end

  def submission_params
    params.fetch(:submission, {}).permit( :biospec_id,
                                          :biospec_or_cho,
                                          :biospec_search_catalog_number,
                                          :biospec_search_collection_code,
                                          :biospec_search_institution_code,
                                          :biospec_search_occurrence_id,
                                          :cho_id,
                                          :cho_search_catalog_number,
                                          :cho_search_collection_code,
                                          :cho_search_institution_code,
                                          :cho_search_occurrence_id,
                                          :device_id,
                                          :imaging_event_id,
                                          :institution_id,
                                          :media_id,
                                          :processing_event_id,
                                          :raw_or_derived_media,
                                          :parent_media_how_to_proceed,
                                          :parent_media_search,
                                          :parent_media_list,
                                          :taxonomy_search,
                                          :taxonomy_id
      )
  end
end
