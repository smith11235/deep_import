# For DeepImport gem development
# Allow developers to create a db with test models
# Example: https://gist.github.com/schickling/6762581
require 'active_record'
require 'deep_import'

def connect!
  DeepImport.set_db_connection_for_development!
end


Rake.add_rakelib 'lib/deep_import' # tasks needed by consumers (aka rails app) for setup/teardown

namespace :deep_import_development do 
  namespace :db do
    desc "Create the database"
    task :create do
      conn = DeepImport.db_settings_for_development
      db = conn.delete :database
      ActiveRecord::Base.establish_connection(conn)
      ActiveRecord::Base.connection.create_database db 
      puts "Database created."
    end
  
    desc "Drop the database"
    task :drop do
      conn = DeepImport.db_settings_for_development
      db = conn.delete :database
      ActiveRecord::Base.establish_connection(conn)
      ActiveRecord::Base.connection.drop_database db 
      puts "Database deleted."
    end
  
    desc "Migrate the database"
    task :migrate do
      connect!
      migrations = if ActiveRecord.version.version >= '5.2'
                     ActiveRecord::Migration.new.migration_context.migrations
                   else
                     ActiveRecord::Migrator.migrations # TODO: TEST OLDER VERSION
                   end

      ActiveRecord::Migrator.new(:up, migrations, nil).migrate
 
      #ActiveRecord::Migrator.migrate("spec/support/db/migrate/")
  
      Rake::Task["deep_import_development:db:schema"].invoke
      puts "Database migrated."
    end
  
    desc "Reset the database"
    task :reset => [:drop, :create, :migrate]
  
    desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
    task :schema do
      connect!
      require 'active_record/schema_dumper'
      filename = "spec/support/db/schema.rb"
      File.open(filename, "w:utf-8") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end

end