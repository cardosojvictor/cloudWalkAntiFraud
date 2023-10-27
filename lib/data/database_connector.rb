require 'active_record'
require_relative 'database_connector'

class DatabaseConnector
  def self.connect(environment)
    Dir.chdir('../config/')
    db_config = YAML.load_file('database.yml')[environment.to_s]
    ActiveRecord::Base.establish_connection(db_config)
  end
end
