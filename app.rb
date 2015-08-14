# https://gist.github.com/madzhuga/4875c98eea03811d1611
#
# Using minimal rails application with unicorn
# Rails 4.2.3
# ruby 2.2
#
# Start:
#   unicorn -p 3000
#
# And open:
#
#   http://localhost:3000/
#

require 'mysql2'

require 'rails'
require 'action_controller/railtie'
require 'active_record'
require 'active_record/tasks/mysql_database_tasks'

require 'socket'

DB_DIR = File.expand_path('../db', __FILE__)

db_yml = ERB.new(File.read(File.join(DB_DIR, 'database.yml'))).result
DB_CONFIG = YAML.load(db_yml)

ActiveRecord::Base.establish_connection(DB_CONFIG[Rails.env])

class QuoteOfTheDay < Rails::Application
  routes.append do
    root to: 'quotes#index'
    get '/quotes' => 'quotes#index'
  end

  config.middleware.delete 'Rack::Lock'
  config.middleware.delete 'ActionDispatch::Flash'
  config.middleware.delete 'Rack::ETag'
  config.middleware.delete 'ActionDispatch::BestStandardsSupport'
  config.middleware.delete 'ActionDispatch::ShowExceptions'
  config.middleware.delete 'ActionDispatch::DebugExceptions'
  config.middleware.delete 'ActiveSupport::Cache::Strategy::LocalCache::Middleware'
  config.middleware.delete 'ActionDispatch::RemoteIp'
  config.middleware.delete 'ActionDispatch::Cookies'
  config.middleware.delete 'ActionDispatch::Callbacks'
  config.middleware.delete 'ActionDispatch::Session::CookieStore'
  config.middleware.delete 'Rack::Head'

  config.log_level = :info

  config.cache_classes = true

  config.secret_token = '7d4eb05bc624d065ad2addf2cd4143ed'
  config.secret_key_base = 'hola'
  config.eager_load = true
end

class QuotesController < ActionController::Metal
  include AbstractController::Rendering
  include ActionController::Rendering
  include ActionView::Layouts

  append_view_path "#{Rails.root}/views"

  def index
    @quote = Quote.random.first
    @total_count = Quote.count
    @hostname = Socket.gethostname

    render 'quotes/index', layout: 'application'
  end
end

class Quote < ActiveRecord::Base
  validates :quote, :author, presence: true
  validates :quote, uniqueness: true

  scope :random, -> { order('rand()') }
end

QuoteOfTheDay.initialize!

unless Rails.env.test?
  puts '>> Launching Rails lightweight stack'
  Rails.configuration.middleware.each do |middleware|
    puts "use #{middleware.inspect}"
  end

  puts "run #{Rails.application.class.name}.routes"
end
