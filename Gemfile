source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.4'
# Use postgresql for all environments, not just production
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'figaro'
gem 'redis'
gem 'rsolr', '>= 1.0'
gem 'jquery-rails'
gem 'devise'
gem 'devise-guests', '~> 0.6'

gem 'riiif', '~> 1.1'

# pul_uv_rails fork upgraded for universal viewer v3 beta
gem 'pul_uv_rails', :git => 'https://github.com/JuliaWinchester/pul_uv_rails.git'

# pull iiif_manifest fork that can handle 3D manifests
gem 'iiif_manifest', :git => 'https://github.com/JuliaWinchester/iiif_manifest.git'

gem 'hyrax', '2.4.1'
gem 'hydra-role-management'

gem 'resque'
gem 'resque-pool'
gem 'resque-web', require: 'resque_web'

gem 'puma', '~> 3.7'

gem 'zipline', '~> 1.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'solr_wrapper', '~> 2.0.0'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rails-controller-testing'
  gem 'factory_bot_rails', '~> 4.8'
  gem 'webmock'
  gem 'geckodriver-helper'
  gem 'shoulda-callback-matchers', '~> 1.1.1'
  gem 'shoulda-matchers', '~> 3.1'
end

group :production do
  gem 'passenger'
  gem 'therubyracer', platforms: :ruby
end
