require 'spec_helper'

describe 'DeepImport.import - General API' do

	before( :all ){ ConfigHelper.new.valid_config }
	before( :each ){ delete_models }
	after( :each ){ 
		DeepImport.mark_ready_for_import! 
		delete_models
	}

	it "should be ready for import after import" do
		DeepImport.import { Parent.new }
		DeepImport.should be_ready_for_import
	end

	it "should track new models" do
		DeepImport.import { Parent.new }
		Parent.all.count.should == 1 
	end

	it "should cause save to raise an error" do
		expect { DeepImport.import { Parent.new.save } }.to raise_error
	end

	it "should cause save! to raise an error" do
		expect { DeepImport.import { Parent.new.save! } }.to raise_error
	end

	it "should track belongs_to build_other associations" do
		DeepImport.import do
			grand_child = GrandChild.new
			grand_child.build_child
		end
		expect { GrandChild.first.child.id }.to_not raise_error
	end

	it "should cause belongs_to create_other to raise an error" do
		expect {
			DeepImport.import do
			grand_child = GrandChild.new
			grand_child.create_child
			end
		}
	end
end
