module Hyrax
  module Actors
    class CulturalHeritageObjectActor < Hyrax::Actors::BaseActor

      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def update(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def generated_title(env)
        attrs = env.attributes
        case
        when attrs['collection_code'].present? || attrs['catalog_number'].present? || attrs['short_title'].present?
          collection_catalog_short_title_generated_title(attrs['collection_code'], attrs['catalog_number'],
                                                         attrs['short_title'])
        when attrs['identifier'].present?
          identifier_generated_title(attrs['identifier'])
        when env.curation_concern.depositor.present?
          fallback_generated_title(attrs['vouchered'], ::User.find_by_user_key(env.curation_concern.depositor))
        else
          fallback_generated_title(attrs['vouchered'], env.current_ability.current_user)
        end
      end

      private

      def collection_catalog_short_title_generated_title(collection_code, catalog_number, short_title)
        case
        when collection_code.present? && catalog_number.present? && short_title.present?
          "#{collection_code.first}:#{catalog_number.first} #{short_title.first}"
        when collection_code.present? && catalog_number.present?
          "#{collection_code.first}:#{catalog_number.first}"
        when collection_code.present? && short_title.present?
          "#{collection_code.first} #{short_title.first}"
        when catalog_number.present? && short_title.present?
          "#{catalog_number.first} #{short_title.first}"
        when collection_code.present?
          collection_code.first
        when catalog_number.present?
          catalog_number.first
        when short_title.present?
          short_title.first
        end
      end

      def identifier_generated_title(identifier)
        identifier.sort.join(', ')
      end

      def fallback_generated_title(vouchered, user)
        voucher_term = vouchered.first == 'Yes' ? 'Vouchered' : 'Unvouchered'
        user_term = user.display_name.present? ? user.display_name : user.user_key
        I18n.t('morphosource.fallback_object_title', voucher: voucher_term, user: user_term)
      end

    end
  end
end
