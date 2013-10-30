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

		it "should have removed all DeepImport* models"

		it "should have removed the migration file"

		it "should have removed deep_import_id's from source model tables"

		it "should have removed deep_import_* tables"

	end

end
