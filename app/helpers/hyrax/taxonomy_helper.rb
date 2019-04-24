module Hyrax::TaxonomyHelper

  def contributing_user_link(taxonomy)
    user = taxonomy.contributing_user
    link_to((user.display_name || user.email).concat(': '), Hyrax::Engine.routes.url_helpers.user_path(user), {:class => "contributing-user"})
  end

end
