module Importer
  module Factory
    class InstitutionFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Institution

    end
  end
end
