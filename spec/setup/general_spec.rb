require 'spec_helper'

describe "rake deep_import:setup" do

	before( :all ) {
		ConfigHelper.new.valid_config
		DeepImport::Config.new 
	}

	it "should execute successfully" do
		expect { system( 'rake deep_import:setup' ) or raise "rake deep_import:setup failed" }.to_not raise_error
	end

	describe "after setup" do
		before( :all ) { 
			system( 'rake deep_import:setup' ) or raise "rake deep_import:setup failed"
		}

		describe "schema migration" do
			let( :migration_file_pattern ){ File.join( "db", "migrate", "*_" + "AddDeepImportEnhancements".underscore + ".rb" ) }

			it "should be 1 single migration" do
				Dir.glob( migration_file_pattern ).size.should eq(1)
			end

			table_name = "parents"	
			describe "changes for: #{table_name}" do
				it "should have #{table_name}.deep_import_id column" do
					ActiveRecord::Base.connection.should be_column_exists( table_name, :deep_import_id, :string )
				end
				it "should have a 'di_id_index' on #{table_name}" do
					ActiveRecord::Base.connection.should be_index_exists( table_name, [:deep_import_id, :id], :name => "di_id_index" )
				end
			end
			table_name = "children"	
			describe "changes for: #{table_name}" do
				it "should have #{table_name}.deep_import_id column" do
					ActiveRecord::Base.connection.should be_column_exists( table_name, :deep_import_id, :string )
				end
				it "should have a 'di_id_index' on #{table_name}" do
					ActiveRecord::Base.connection.should be_index_exists( table_name, [:deep_import_id, :id], :name => "di_id_index" )
				end
			end
			table_name = "grand_children"	
			describe "changes for: #{table_name}" do
				it "should have #{table_name}.deep_import_id column" do
					ActiveRecord::Base.connection.should be_column_exists( table_name, :deep_import_id, :string )
				end
				it "should have a 'di_id_index' on #{table_name}" do
					ActiveRecord::Base.connection.should be_index_exists( table_name, [:deep_import_id, :id], :name => "di_id_index" )
				end
			end

			model_class = Child 
			describe "Generated Model: DeepImport#{model_class}" do
				let( :expected_model_file ){ "app/models/deep_import_#{model_class.to_s.underscore}.rb" }
				it "should have model definition file" do
					File.should be_file( expected_model_file ) 
				end
				let( :deep_model_class ){ "DeepImport#{model_class}".constantize }
				it "should expose deep_import_id" do
					deep_model_class.column_names.should include( 'deep_import_id' )
				end
				let( :deep_model_table ){ "DeepImport#{model_class}".tableize }
				it "should have a table" do
					ActiveRecord::Base.connection.should be_table_exists( deep_model_table )
				end
				it "should have a 'deep_import_id' column in it's table" do
					ActiveRecord::Base.connection.should be_column_exists( deep_model_table, :deep_import_id, :string )
				end


				describe "tracks #{Parent}" do
					let( :deep_model_class ){ "DeepImport#{model_class}".constantize }
					let( :association_field ){ "deep_import_#{Parent.to_s.underscore}_id".to_sym }
					it "should have a reference field in it's table" do
						ActiveRecord::Base.connection.should be_column_exists( deep_model_table, association_field, :string )
					end

					let( :index_name ){ "di_#{Parent.to_s.underscore}" }
					it "should have an index for this reference in it's table" do
						ActiveRecord::Base.connection.should be_index_exists( deep_model_table, [:deep_import_id, association_field], :name => index_name )
					end

					it "should expose this reference field to it's model class" do
						deep_model_class.column_names.should include( association_field.to_s )
					end

				end
			end

			describe "Generated Model: DeepImport#{GrandChild}" do
				let( :expected_model_file ){ "app/models/deep_import_#{GrandChild.to_s.underscore}.rb" }
				it "should have model definition file" do
					File.should be_file( expected_model_file ) 
				end
				let( :deep_model_class ){ "DeepImportGrandChild".constantize }
				it "should expose deep_import_id" do
					deep_model_class.column_names.should include( 'deep_import_id' )
				end
				let( :deep_model_table ){ "DeepImport#{GrandChild}".tableize }
				it "should have a table" do
					ActiveRecord::Base.connection.should be_table_exists( deep_model_table )
				end
				it "should have a 'deep_import_id' column in it's table" do
					ActiveRecord::Base.connection.should be_column_exists( deep_model_table, :deep_import_id, :string )
				end


				describe "tracks Child" do
					let( :association_field ){ "deep_import_#{Child.to_s.underscore}_id".to_sym }
					it "should have a reference field in it's table" do
						ActiveRecord::Base.connection.should be_column_exists( deep_model_table, association_field, :string )
					end

					let( :index_name ){ "di_#{Child.to_s.underscore}" }
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

