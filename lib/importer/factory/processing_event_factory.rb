module Importer
  module Factory
    class ProcessingEventFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = ProcessingEventFactory

    end
  end
end
