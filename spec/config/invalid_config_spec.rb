require 'spec_helper'

describe 'DeepImport::Config - General API' do
	after( :all ) do
		# print out a fresh simple config 
		# for Parents, Children, and GrandChildren
		#ConfigHelper.new.valid_config 
		# and parse the config so it's defs are loaded for testing
	end

	it "should be invalid if any of the keys/values are incorrect or unknown"

end
