
module Hyrax
  class SuppliedRecordBadge
    include ActionView::Helpers::TagHelper

    # @param idigbio_uuid [String] the current idigbio_uuid
    def initialize(idigbio_uuid)
      @idigbio_uuid = idigbio_uuid
    end

    # Draws a span tag with styles for a bootstrap label
    def render
      content_tag(:span, text, class: "label label-primary")
    end

    private

      def text
        if @idigbio_uuid.present?
          'Institution Supplied Record'
        else
          'User Supplied Record'
        end
      end

  end
end