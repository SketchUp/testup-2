source 'https://rubygems.org'

# Even if you configure Bundler to install only one group it will fail if any
# of the unused groups have dependencies that cannot be resolved.
# On Ruby 3.2 the Minitest 5.4.3 will fail, so applying this kludge to work
# around that until Minitest is updated.
# TODO: Look into removing this now that we're on Minitest 5.15. Though, does it
# add much time for the CI run?
CI_BUILD = ENV['CI']

group :development do
  gem 'colorize', '~> 0.8.1'
  gem 'minitest', '5.15.0'
  gem 'minitest-reporters-json_reporter'
  gem 'rubyzip', '~> 1.2'
  gem 'sketchup-api-stubs'
  gem 'skippy', '~> 0.5.2.a'
  gem 'solargraph'
end unless CI_BUILD

group :analytics do
  gem 'rubocop', '>= 1.72', '< 2.0'
  gem 'rubocop-sketchup', '~> 2.1.1'
  gem 'rubocop-performance', '~> 1.15'
end
