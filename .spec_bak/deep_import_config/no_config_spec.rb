require 'spec_helper'
describe "No config/deep_import.rb Provided" do
	before( :all ) { ConfigHelper.new.remove_config }
	after( :all ) { ConfigHelper.new.valid_config }

	describe "DeepImport's environment status" do
		it "should be :inactive"
		# ^^ as found and set by the config parsing in the Railtie
	end

end
