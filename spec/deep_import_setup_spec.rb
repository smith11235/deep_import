require 'spec_helper'

describe "DeepImport::Setup" do

=begin
- test that models are configured correctly
	- deep_import_id and index on base models
	- deep_import_* classes, with proper associations
=end

	describe "Application Model Table Migrations" do

		DeepImport::Config.models.keys.each do |model_class|
			describe "#{model_class}" do
				it "should have deep_import_id" do
					table_symbol = model_class.to_s.pluralize.tableize.to_s
					ActiveRecord::Base.connection.should be_column_exists( model_class.to_s.tableize, :deep_import_id, :string )
				end
				it "should have di_id_index" do
					ActiveRecord::Base.connection.should be_index_exists( model_class.to_s.tableize, [:deep_import_id, :id], :name => "di_id_index" )
				end
			end
		  	
		end
	end
 # for each model in config:
		# - column_exists?(:suppliers, :name, :string)
		# - index_exists? :plural_of_model, [:deep_import_id, :id], :name => "di_id_index"
	

end
