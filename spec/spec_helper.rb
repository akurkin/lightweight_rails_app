ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../app', __FILE__)
require 'rspec/rails'

ActiveRecord::Base.maintain_test_schema = true
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
end
