require 'spec_helper'

describe 'DeepImport::Config - General API' do
	before( :all ) do
		# print out a fresh simple config 
		# for Parents, Children, and GrandChildren
		ConfigHelper.new.valid_config 
		# and parse the config so it's defs are loaded for testing
	end

	it "should be a valid config when initialized" do
		DeepImport::Config.new.should be_valid
	end

	describe "DeepImport::Config.models" do
		let(:models){ DeepImport::Config.models }

		let(:expected_models){
			# return a Hash of ModelClass to Hash of :belongs_to => Array of ClassName
			{
				Parent => { :belongs_to => Hash.new },
				Child => { :belongs_to => { Parent => true } },
				GrandChild => { :belongs_to => { Child => true } }
			}
		}

		describe "expected models" do

			it "should have the same keys" do
				models.keys.should =~ expected_models.keys
			end

			it "should have the same values" do
				models.values.should =~ expected_models.values
			end

			it "should have Child belongs_to Parent" do
				models[Child][:belongs_to].keys.should =~ expected_models[Child][:belongs_to].keys
			end

			it "should have GrandChild belongs_to Child" do
				models[GrandChild][:belongs_to].keys.should =~ expected_models[GrandChild][:belongs_to].keys
			end

		end

	end

end
