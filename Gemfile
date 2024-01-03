source 'https://rubygems.org'

# Even if you configure Bundler to install only one group it will fail if any
# of the unused groups have dependencies that cannot be resolved.
# On Ruby 3.2 the Minitest 5.4.3 will fail, so applying this kludge to work
# around that until Minitest is updated.
CI_BUILD = ENV['CI']

group :development do
  gem 'colorize', '~> 0.8.1'
  gem 'minitest', '5.4.3'
  gem 'minitest-reporters-json_reporter'
  gem 'rubyzip', '~> 1.2'
  gem 'sketchup-api-stubs'
  gem 'skippy', '~> 0.5.1.a'
  gem 'solargraph'
end unless CI_BUILD

group :analytics do
  gem 'rubocop', '>= 0.82', '< 2.0'
  gem 'rubocop-sketchup', '~> 1.3.0'
  gem 'rubocop-performance', '~> 1.15.0'
end
