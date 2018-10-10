# require 'displays_mesh'

module Hyrax
	class MediaFileSetPresenter < Hyrax::FileSetPresenter
		include DisplaysMesh

		delegate :mesh?, :mesh_mime_type, to: :solr_document
	end
end
