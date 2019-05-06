# Generated via
#  `rails generate hyrax:work ImagingEvent`
module Hyrax
  module Actors
    class ImagingEventActor < Hyrax::Actors::BaseActor
      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def update(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def generated_title(env)
        # <device parent manufacturer> <device parent name> <modality> Imaging Event (<date created>)
        # For device parent fields and modality field, blank if no value
        # For date created, if no value should be “(No Event Date)”
        attrs = env.attributes
        work_parents = ''
        if attrs['work_parents_attributes'].present?
          attrs['work_parents_attributes'].each do |key, wp|
            work_parent = Morphosource::Works::Base.find(wp['id'])
            work_parent_string = case work_parent.class.to_s
              when 'Device'
                "#{work_parent.creator.first} #{work_parent.title.first}"
              # when 'BiologicalSpecimen'
              #   "S#{wp['id']} "
              # when 'CulturalHeritageObject'
              #   "C#{wp['id']} "
            end
            work_parents += "#{work_parent_string} "
          end
        end
        date_created = attrs['date_created'].present? ? attrs['date_created'].first : 'No Event Date'
        modality = attrs['modality'].present? ? "#{attrs['modality'].first} " : ''
        "#{work_parents}#{modality}Imaging Event (#{date_created})"
      end
    end
  end
end
