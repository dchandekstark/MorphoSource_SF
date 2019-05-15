module Hyrax::TaxonomyHelper

  def contributing_user_link(taxonomy)
    user = taxonomy.contributing_user
    display_email = user.email.dup
    link_to((user.display_name || display_email).concat(': '), Hyrax::Engine.routes.url_helpers.user_path(user), {:class => "contributing-user"})
  end

end
