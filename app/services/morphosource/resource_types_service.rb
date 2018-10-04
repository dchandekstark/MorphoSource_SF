# app/services/morphosource/resource_types_service.rb
module Morphosource
  # Provide select options for the resource_type field

  class ResourceTypesService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('resource_types')
    end

    def include_current_value(value, _index, render_options, html_options)
          unless value.blank? || active?(value)
            html_options[:class] << ' force-select'
            render_options += [[label(value) { value }, value]]
          end
          [render_options, html_options]
        end


  end
end