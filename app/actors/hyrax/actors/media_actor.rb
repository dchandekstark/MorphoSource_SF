# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  module Actors
    class MediaActor < Hyrax::Actors::BaseActor

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
        parts = attrs['part'].presence || ['Element unspecified']
        media_type = attrs['media_type']&.first.presence || ''
        modality = attrs['modality'].presence || []
        modality_abbrevs = modality.map { |m| modality_abbrev(m) }

        id = attrs['id'].presence || env.curation_concern.id.presence || ''
        id_prefix = id.presence ? id.to_s+': ' : ''

        id_prefix + parts.sort.join(', ').titleize + (media_type.presence ? ' [' + media_type.to_s + ']' : '') + (modality_abbrevs.presence ? ' [' + modality_abbrevs.join('/')+ ']' : '')
      end

      private

      def generated_title_modalities(attrs)
        attrs['modality'].map { |m| modalities_service.label(m) }.sort.join(', ')
      end

      def generated_title_parts(attrs)
        attrs['part'].sort.join(', ').titleize
      end

      def modality_abbrev(m)
        case m
        when 'MicroNanoXRayComputedTomography'
          'μCT'
        when 'MedicalXRayComputedTomography'
          'CT'
        when 'MagneticResonanceImaging'
          'MRI'
        when 'PositronEmissionTomography'
          'PET'
        when 'SynchrotronImaging'
          'Synchro'
        when 'NeutrinoImaging'
          'Neutrino'
        when 'Photogrammetry'
          'Photogram'
        when 'StructuredLight'
          'StrLight'
        when 'LaserScan'
          'Laser'
        when 'ConfocalImageStacking'
          'Confocal'
        when 'ReflectanceTransformationImaging'
          'RTI'
        when 'Photography'
          'Photo'
        when 'ScanningElectronMicroscopy'
          'SEM'
        else
          'Etc' 
        end
      end

      def modalities_service
        @modalities_service ||= Morphosource::ModalitiesService.new
      end

    end
  end
end
