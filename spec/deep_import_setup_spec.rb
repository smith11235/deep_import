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
		DeepImport::Config.models.each do |model_class,info|
			deep_model_class = "DeepImport#{model_class}".constantize
			deep_model_table = "DeepImport#{model_class}".tableize
			describe "#{deep_model_class}" do

				describe "Schema Migration" do
					it "should have one and only one migration file" do
						migration_name = "Create#{deep_model_class.to_s.pluralize}".underscore
						Dir.glob( File.join( Rails.root, "db", "migrate", "*_#{migration_name}.rb" ) ).size.should eq(1)
					end
					it "should have a table" do
						ActiveRecord::Base.connection.should be_table_exists( deep_model_class.to_s.tableize )
					end
					it "should have deep_import_id" do
						ActiveRecord::Base.connection.should be_column_exists( deep_model_table, :deep_import_id, :string )
					end

					describe "deep_import associations" do
						info[:belongs_to].each do |belongs_to|
							association_field = "deep_import_#{belongs_to.to_s.underscore}_id".to_sym
							it "should have an association field for: #{belongs_to}" do
								ActiveRecord::Base.connection.should be_column_exists( deep_model_table, association_field, :string )
							end
							index_name = "di_#{belongs_to.to_s.underscore}"
							it "should have a #{index_name} index" do
								ActiveRecord::Base.connection.should be_index_exists( deep_model_table, [:deep_import_id, association_field], :name => index_name )
							end
						end
					end

				end

				describe "Model Class" do
					it "should have model def file" do
						Dir.glob( File.join( Rails.root, "app", "models", "#{deep_model_class.to_s.underscore}.rb" ) ).size.should eq(1)
					end
					it "should have deep_import_id" do
						deep_model_class.column_names.should include( 'deep_import_id' )
					end
					info[:belongs_to].each do |belongs_to|
						association_field = "deep_import_#{belongs_to.to_s.underscore}_id"
						it "should have #{association_field}" do
							deep_model_class.column_names.should include( association_field )
						end
					end
				end

			end
		end
	end

end
