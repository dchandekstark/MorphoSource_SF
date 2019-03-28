module Morphosource
  module Ability
    extend ActiveSupport::Concern
    included do
      include Hyrax::Ability
    end

    def download_groups(id)
      Rails.logger.info('Morphosource::Ability.download_groups called')
      return []
    end
    def download_users(id)
      Rails.logger.info('Morphosource::Ability.download_users called')
      return []
    end
  end
end
    
<<<<<<< HEAD
Hyrax::Ability.prepend Morphosource::Ability
=======
Hyrax::Ability.prepend Morphosource::Ability
>>>>>>> cc9bd7e4be63bd1662c7b92348ac910f12d80b4b
