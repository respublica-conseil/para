$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'para/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'para'
  s.version     = Para::VERSION
  s.authors     = ['Valentin Ballestrino']
  s.email       = ['contact@glyph.fr']
  s.homepage    = 'http://github.com/glyph-fr/para'
  s.summary     = 'Rails admin engine'
  s.description = 'Rails admin engine'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib,vendor}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'active_decorator', '~> 1.0'
  s.add_dependency 'activejob-status'
  s.add_dependency 'cancancan', '~> 3.0'
  s.add_dependency 'closure_tree', '~> 7.0'
  s.add_dependency 'cocoon'
  s.add_dependency 'deep_cloneable', '>= 2.2.1'
  s.add_dependency 'devise', '>= 3.0', '< 5.0'
  s.add_dependency 'friendly_id', '~> 5.1'
  s.add_dependency 'kaminari'
  s.add_dependency 'paperclip', '>= 4.2', '< 7.0'
  s.add_dependency 'rails', '>= 4.0', '<= 8.0'
  s.add_dependency 'rails-i18n'
  s.add_dependency 'ransack'
  s.add_dependency 'request_store'
  s.add_dependency 'roo'
  s.add_dependency 'roo-xls'
  s.add_dependency 'simple_form', '>= 3.1'
  s.add_dependency 'spreadsheet'
  s.add_dependency 'stimulus-rails'
  s.add_dependency 'truncate_html'
  s.add_dependency 'turbo-rails'

  s.add_dependency 'font-awesome-rails', '~> 4.7.0'
  s.add_dependency 'haml-rails'

  s.add_dependency 'rspec-core'

  s.add_dependency 'pg'
end
