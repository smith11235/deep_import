require 'spec_helper'

describe 'DeepImport::Config - General API' do
	before( :all ) { ConfigHelper.new.valid_config }

	describe "method: models" do
		let(:models){ DeepImport::Config.models }

		it "should be a Hash" do
			models.should be_instance_of(Hash)
		end

		describe "Model entries should all be ClassName => Hash { :belongs_to => [] }" do
			it "should have constants as keys" do
			end
		end
		it "should have ClassName constants as keys"
		it "should have Hashes for each of the values"
		it "should have :belongs_to"
		it "should have an Array of Model Classes for :belongs_to"

	end


end
