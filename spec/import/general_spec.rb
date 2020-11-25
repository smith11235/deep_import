require 'spec_helper'

describe 'DeepImport.import - General API' do

	it "should not be active by default" do
		expect(Parent.new.deep_import_id).to be_nil
	end

	it "should be ready for import after import" do
		DeepImport.import { Parent.new }
		DeepImport.should be_ready_for_import
	end

	it "should track new models" do
		DeepImport.import { 
		  expect(Parent.count).to eq(0) # REMOVE
      p = Parent.new 
      expect(p.deep_import_id).to be_present
		  expect(Parent.count).to eq(0)
    }
		expect(Parent.count).to eq(1)
	end

	it "should set deep_import_id to nil after commit" do
		DeepImport.import { Parent.new }
		Parent.first.deep_import_id.should == nil
	end

	it "should cause save to raise an error" do
		expect { DeepImport.import { Parent.new.save } }.to raise_error
	end

	it "should cause save! to raise an error" do
		expect { DeepImport.import { Parent.new.save! } }.to raise_error
	end

	it "should track belongs_to build_other associations" do
		DeepImport.import do
			grand_child = GrandChild.new :name => "abc"
			grand_child.build_child :name => "xyz"
		end
		GrandChild.find_by_name( "abc" ).child.name.should == "xyz"
	end

	it "should cause belongs_to create_other to raise an error" do
		expect {
			DeepImport.import do
				grand_child = GrandChild.new
				grand_child.create_child
			end
		}.to raise_error
	end
end
