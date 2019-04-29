module Hyrax
  module Actors
    class BiologicalSpecimenActor < Hyrax::Actors::BaseActor

      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def update(env)
        env.attributes['title'] = [ generated_title(env) ]
        env.attributes['canonical_taxonomy'] = [ check_canonical_taxonomy(env) ]
        super
      end

      def generated_title(env)
        attrs = env.attributes
        case
        when attrs['collection_code'].present? || attrs['catalog_number'].present?
          collection_catalog_generated_title(attrs['collection_code'], attrs['catalog_number'])
        when attrs['identifier'].present?
          identifier_generated_title(attrs['identifier'])
        when env.curation_concern.depositor.present?
          fallback_generated_title(attrs['vouchered'], ::User.find_by_user_key(env.curation_concern.depositor))
        else
          fallback_generated_title(attrs['vouchered'], env.current_ability.current_user)
        end
      end

      private

      def collection_catalog_generated_title(collection_code, catalog_number)
        case
        when collection_code.present? && catalog_number.present?
          "#{collection_code.first}:#{catalog_number.first}"
        when collection_code.present?
          collection_code.first
        when catalog_number.present?
          catalog_number.first
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

      def check_canonical_taxonomy(env)
        canonical_taxonomy = env.attributes["canonical_taxonomy"]
        return '' if canonical_taxonomy.empty?
        canonical_id = canonical_taxonomy.first
        dissociated_parents = get_dissociated_parents(env)
        dissociated_parents.include?(canonical_id) ? '' : canonical_id
      end

      def get_dissociated_parents(env)
        env.attributes["work_parents_attributes"].each_value.with_object([]) do |v,ids|
          ids << v["id"] if v["_destroy"] == "true"
        end
      end

    end
  end
end
