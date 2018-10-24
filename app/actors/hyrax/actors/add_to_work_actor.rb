# Overrides Hyrax app/actors/hyrax/actors/add_to_work_actor.rb

module Hyrax
  module Actors
    class AddToWorkActor < AbstractActor
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if create was successful
      def create(env)
        parent_works_hash = env.attributes["work_parents_attributes"]
        next_actor.create(env) && add_to_works(env, parent_works_hash)
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        parent_works_hash = env.attributes["work_parents_attributes"]
        add_to_works(env, parent_works_hash) && next_actor.update(env)
      end

      private

        def add_to_works(env, parents)
          return true if parents.nil?
          cleanup_ids_to_remove_from_curation_concern(env, parents)
          add_new_work_ids_not_already_in_curation_concern(env, parents)
          env.curation_concern.errors[:in_works_ids].empty?
        end

        def cleanup_ids_to_remove_from_curation_concern(env, parents)
          work_ids_to_remove = []
          parents.each do |k,v|
            if (v["_destroy"] == "true" && env.curation_concern.in_works_ids.include?(v["id"]))
              work_ids_to_remove << v["id"]
            end
          end

          work_ids_to_remove.each do |old_id|
            work = ::ActiveFedora::Base.find(old_id)
            work.ordered_members.delete(env.curation_concern)
            work.members.delete(env.curation_concern)
            work.save!
          end
        end

        def add_new_work_ids_not_already_in_curation_concern(env, parents)
          work_ids_to_add = []
          parents.each do |k,v|
            if (v["_destroy"] == "false" && env.curation_concern.in_works_ids.exclude?(v["id"]))
              work_ids_to_add << v["id"]
            end
          end
          work_ids_to_add.uniq.each do |work_id|
            work = ::ActiveFedora::Base.find(work_id)
            work.ordered_members << env.curation_concern
            work.save!
          end
        end
    end
  end
end
