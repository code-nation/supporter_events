source 'https://rubygems.org'
ruby "2.3.1"

gem 'rails', '5.0.1'
gem 'puma', '~> 3.0'
gem 'pg', '~> 0.18'

# Third party
gem 'devise', '~> 4.2'
gem 'devise_invitable', '~> 1.7.0'
gem 'oauth2'
gem 'nationbuilder-rb', require: 'nationbuilder'
gem "roo", "~> 2.7.0"
gem 'rack-cors', :require => 'rack/cors'
gem 'cancancan'
gem 'sidekiq'
gem "sinatra", ">= 2.0.0.beta2", require: false
gem 'faraday'

# Assets
gem 'bootstrap-sass', '~> 3.3.6'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem "font-awesome-rails"

# Others
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'sdoc', '~> 0.4.0', group: :doc

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'better_errors'
  gem 'debase'
  gem 'ruby-debug-ide'
  gem "figaro"
end

group :production, :staging do
  # gem 'rails_12factor'
  # gem 'newrelic_rpm'
end
