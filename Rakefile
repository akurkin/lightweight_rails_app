require './app'

include ActiveRecord::Tasks

DatabaseTasks.env = Rails.env
DatabaseTasks.database_configuration = DB_CONFIG

task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection DatabaseTasks.env.to_sym
end

load 'active_record/railties/databases.rake'
