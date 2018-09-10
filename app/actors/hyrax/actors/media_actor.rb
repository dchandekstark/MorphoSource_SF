# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  module Actors
    class MediaActor < Hyrax::Actors::BaseActor

      def create(env)
        concat_scale_bar(env) && super
      end

      def update(env)
        concat_scale_bar(env) && super
      end

      def concat_scale_bar(env)
        scale_bar_target_type = "Type: " + env.attributes[:scale_bar_target_type].first.to_s
        scale_bar_distance = "Distance: " + env.attributes[:scale_bar_distance].first.to_s
        scale_bar_units = "Units: " + env.attributes[:scale_bar_units].first.to_s

        env.attributes[:scale_bar] = [[scale_bar_target_type, scale_bar_distance, scale_bar_units].join(', ')]

        true

      end

    end
  end
end
