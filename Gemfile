source 'https://mirrors.aliyun.com/rubygems/'

gem 'win32-pipe', '~> 0.4.0'
gem 'google-protobuf', '~> 3.21', '>= 3.21.9'

group :development do
  gem 'minitest' # Helps solargraph with code insight when you write unit tests.
  gem 'sketchup-api-stubs'       # VSCode SketchUp Ruby API insight
  gem 'skippy', '~> 0.5.1.a'     # Aid with common SketchUp extension tasks.
  gem 'solargraph'               # VSCode Ruby IDE support
end

group :documentation do
  gem 'commonmarker', '~> 0.23'
  gem 'yard', '~> 0.9'
end

group :analysis do
  gem 'rubocop', '>= 1.30', '< 2.0'  # Static analysis of Ruby Code.
  gem 'rubocop-sketchup', '~> 1.3.0' # Auto-complete for the SketchUp Rub API.
end
