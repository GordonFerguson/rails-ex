source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.1'
# Support postgresql as a database for Active Record
gem 'pg', '~> 0.21'
# Support sqlite3 as a database for Active Record
gem 'sqlite3'
# Support redis as a key-value store for Action Cable
gem 'redis'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'listen', '>= 3.0.5', '< 3.2'
# gem 'wdm', '>= 0.1.0' if Gem.win_platform?
group :development, :test do
  # gem 'wdm', '>= 0.1.0' if Gem.win_platform?
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '~> 2.13'
  # gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# #############################
# gjf tweaks that prcIs40 need
# ##############################
gem "acts_as_list"

gem 'jquery-rails'
gem 'jquery-ui-rails'


# for backwards compat: (there are a couple of lingering .slim files)
# But I don't want to generate any more slim files,
# I want haml --- that's for consistency
# see https://github.com/slim-template/slim-rails#readme
# gem 'slim-rails'

#use haml see http://haml.info/
gem 'haml'
gem 'haml-rails'

# for pagination
gem 'kaminari'

# datagrid for enhanaced tables (it needs kaminari [above] for paging)
# https://github.com/bogdan/datagrid
gem "datagrid"