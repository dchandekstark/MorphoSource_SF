module MorphosourceHelper

  def device_selector
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    hits = devices
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
  end

  def devices
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    qry = "#{Solrizer.solr_name('has_model', :symbol)}:Device"
    ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
  end

  def files_required?(work)
    if Hyrax.config.work_requires_files?
      true
    else
      work.class.work_requires_files?
    end
  end

  def find_works_autocomplete_url(curation_concern, relation)
    valid_concerns = curation_concern.send("valid_#{relation}_concerns").map(&:to_s)
    type_params = valid_concerns.sort.map { |type| "type[]=#{type}" }
    Rails.application.routes.url_helpers.qa_path + '/search/find_works?' + type_params.join('&')
  end

  def institution_selector
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    hits = institutions
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
  end

  def institutions
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    qry = "#{Solrizer.solr_name('has_model', :symbol)}:Institution"
    ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
  end

  def ms_work_form_tabs(work)
    if files_required?(work)
      %w[metadata files relationships]
    else
      %w[metadata relationships]
    end
  end

  # returns a string containing the human-readable names of the valid relation (child/parent) types for the provided
  # curation concern with a comma and space between each class name
  def valid_work_types_list(curation_concern, relation)
    valid_types = curation_concern.send("valid_#{relation}_concerns").map(&:human_readable_type)
    valid_types.sort.join(', ')
  end

  def media_selector
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    hits = media
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
  end

  def media
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    qry = "#{Solrizer.solr_name('has_model', :symbol)}:Media"
    ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
  end

  def find_media_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_works?type[]=Media&id=NA&q='
  end
  
  def collapse_expand_panel(block, state:"COLLAPSE", expand_button_text:"Show more", collapse_button_text:"Show less")
    content_tag :div, :class => "row collapse-button" do
      content_tag :div, :class => "panel-title" do
        content_tag :a, :data => {:toggle => "collapse"}, :href => %(##{block}), :class => "btn #{block}" do
          concat content_tag(:span, "", class: "glyphicon glyphicon-triangle-bottom")
          concat "Show more"
          concat content_tag(:span, "", class: "glyphicon glyphicon-triangle-bottom")
        end
      end
    end
  end

  def collapse_accordion_panel(block, data_parent, label, value, is_collapsed)
    if is_collapsed == true
      icon = "glyphicon-triangle-top"
    else
      icon = "glyphicon-triangle-bottom"
    end
    content_tag :a, :data => {:toggle => "collapse", :parent => %(##{data_parent})}, :href => %(##{block}) do
      content_tag :div, :class => "row" do
        concat content_tag(:div, label, class: "col-xs-6 showcase-label")
        concat content_tag(:div, value, class: "col-xs-5 showcase-value")
        concat content_tag(:span, "", class: "col-xs-1 glyphicon #{icon} collapse-taxonomy-1")
      end
    end
  end





end
