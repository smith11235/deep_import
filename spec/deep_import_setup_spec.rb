require 'spec_helper'

describe "DeepImport::Setup" do

=begin
- test that models are configured correctly
	- deep_import_* classes, with proper associations
=end

	describe "Application Model Schema Migrations" do

		DeepImport::Config.models.keys.each do |model_class|
			describe "#{model_class}" do
				it "should have one and only one migration file" do
					migration_name = "AddDeepImportIdTo#{model_class.to_s.pluralize}".underscore
					Dir.glob( File.join( Rails.root, "db", "migrate", "*_#{migration_name}.rb" ) ).size.should eq(1)
				end
				it "should have deep_import_id" do
					ActiveRecord::Base.connection.should be_column_exists( model_class.to_s.tableize, :deep_import_id, :string )
				end
				it "should have di_id_index" do
					ActiveRecord::Base.connection.should be_index_exists( model_class.to_s.tableize, [:deep_import_id, :id], :name => "di_id_index" )
				end
			end

		end
	end

	describe "Deep Import Models" do
		DeepImport::Config.models.keys.each do |model_class|
			deep_model_class = "DeepImport#{model_class}".constantize
			deep_model_table = "DeepImport#{model_class}".tableize

			describe "#{deep_model_class}" do

				describe "Schema Migration" do
					# - migration file
					# - table exists
					# - table has X fields
					# - table has X indicies
				end

				describe "Model Class" do
					# model file exists
					# - responds to fields
					# - whatever else it has
				end

			end
		end
	end

end
