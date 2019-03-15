# require 'displays_mesh'

module Hyrax
	class MediaFileSetPresenter < Hyrax::MsFileSetPresenter
		include DisplaysMesh

		delegate :mesh?, to: :solr_document
	end
end
