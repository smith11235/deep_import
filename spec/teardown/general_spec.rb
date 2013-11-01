require 'spec_helper'

describe "rake deep_import:teardown" do

	before( :all ) {
		ConfigHelper.new.valid_config
		DeepImport::Config.new 
	}
	after( :all ) {
		ConfigHelper.new.valid_config
		system( 'rake deep_import:setup' ) or raise "rake deep_import:setup failed"
	}

	it "should execute successfully" do
		expect { system( 'rake deep_import:teardown' ) or raise "rake deep_import:teardown failed" }.to_not raise_error
	end

	describe "after execution" do
		before( :all ) {
			system( 'rake deep_import:teardown' ) or raise "rake deep_import:teardown failed"
		}

	
		describe "generated files" do
			it "should have removed the model files" do
				generated_files = Dir.glob( "app/models/deep_import_*.rb" )
				generated_files.size.should == 0
			end
			it "should have removed the migration file" do
				generated_files = Dir.glob( "db/migrate/*_deep_import_*.rb" )
				generated_files.size.should == 0
			end
		end

		describe "schema changes" do
			# test fields, index's will have to have been removed
			it "should have removed deep_import_id's from parents" do
				ActiveRecord::Base.connection.should_not be_column_exists( "parents", :deep_import_id, :string )
			end
			it "should_not have removed deep_import_id's from children" do
				ActiveRecord::Base.connection.should_not be_column_exists( "children", :deep_import_id, :string )
			end
			it "should_not have removed deep_import_id's from grand_children" do
				ActiveRecord::Base.connection.should_not be_column_exists( "grand_children", :deep_import_id, :string )
			end

			it "should_not have removed deep_import_parents" do
				ActiveRecord::Base.connection.should_not be_table_exists( "deep_import_parents" )
			end
			it "should_not have removed deep_import_children" do
				ActiveRecord::Base.connection.should_not be_table_exists( "deep_import_children" )
			end
			it "should_not have removed deep_import_grand_children" do
				ActiveRecord::Base.connection.should_not be_table_exists( "deep_import_grand_children" )
			end

		end

	end

end
