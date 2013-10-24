require 'spec_helper'

describe "DeepImport::Setup" do

	migration_search = File.join( "db", "migrate", "*_" + "AddDeepImportEnhancements".underscore + ".rb" )
	it "should have 1 migration file matching: #{migration_search}" do
		Dir.glob( migration_search ).size.should eq(1)
	end

	# source model changes
	DeepImport::Config.models.keys.each do |model_class|
		describe "Changes To Model: #{model_class}" do

			let( :table_name ){ model_class.to_s.tableize }

			it "Table for #{model_class} should have column 'deep_import_id'" do
				ActiveRecord::Base.connection.should be_column_exists( table_name, :deep_import_id, :string )
			end

			it "Table for #{model_class} should have index 'di_id_index'" do
				ActiveRecord::Base.connection.should be_index_exists( table_name, [:deep_import_id, :id], :name => "di_id_index" )
			end
		end
	end

	# deep import generated models
	DeepImport::Config.models.each do |model_class,info|
		describe "Generated Model: DeepImport#{model_class}" do

			let( :expected_model_file ){ "app/models/deep_import_#{model_class.to_s.underscore}.rb" }
			it "should have model definition file" do
				File.should be_file( expected_model_file ) 
			end

			let( :deep_model_table ){ "DeepImport#{model_class}".tableize }
			it "should have a table" do
				ActiveRecord::Base.connection.should be_table_exists( deep_model_table )
			end
			it "should have a 'deep_import_id' column in it's table" do
				ActiveRecord::Base.connection.should be_column_exists( deep_model_table, :deep_import_id, :string )
			end
			
			let( :deep_model_class ){ "DeepImport#{model_class}".constantize }
			it "should expose deep_import_id" do
				deep_model_class.column_names.should include( 'deep_import_id' )
			end

			describe "Belongs To Relations" do
				info[:belongs_to].each do |belongs_to|

					describe "-> DeepImport#{belongs_to}" do

						let( :association_field ){ "deep_import_#{belongs_to.to_s.underscore}_id".to_sym }
						it "should have a reference field in it's table" do
							ActiveRecord::Base.connection.should be_column_exists( deep_model_table, association_field, :string )
						end

						let( :index_name ){ "di_#{belongs_to.to_s.underscore}" }
						it "should have an index for this reference in it's table" do
							ActiveRecord::Base.connection.should be_index_exists( deep_model_table, [:deep_import_id, association_field], :name => index_name )
						end

						it "should expose this reference field to it's model class" do
							deep_model_class.column_names.should include( association_field.to_s )
						end

					end
				end

			end


		end
	end

end
