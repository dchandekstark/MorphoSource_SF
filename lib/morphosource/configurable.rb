module Morphosource
  module Configurable
    extend ActiveSupport::Concern

    included do

      # Geonames user account
      mattr_accessor :geonames_user do
        ENV["GEONAMES_USER"] || "NOT_SET"
      end

    end

  end
end
