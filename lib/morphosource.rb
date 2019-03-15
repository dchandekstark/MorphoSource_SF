module Morphosource
  extend ActiveSupport::Autoload

  autoload :Configurable

  include Morphosource::Configurable

  module Works
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :MimeTypes
  end

end
