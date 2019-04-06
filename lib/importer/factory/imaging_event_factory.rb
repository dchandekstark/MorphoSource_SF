module Importer
  module Factory
    class ImagingEventFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = ImagingEventFactory

    end
  end
end
