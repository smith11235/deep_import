require 'spec_helper'

describe 'Postgres Compatibility' do

	before(:all) {
		ConfigHelper.new.valid_config 
		DeepImport.initialize!
		delete_models

		# now load some models to make sure it works
		DeepImport.import do
			%w(a b).each do |name|
				parent = Parent.new :name => name

				child = Child.new :name => name
				child.parent = parent

			end
		end
	}

	after( :all ) {
		delete_models
	}

	it "should be connected through a postgres adapter" do
		ActiveRecord::Base.connection_config[:adapter].should == "postgresql"
	end

	it "should have a couple parents" do
		Parent.count.should == 2
	end

=begin
	%w(a b).each do |name|
		describe "Child - Parent relation for name=#{name}" do
			it "should have a child with name=#{name}" do
				Child.find_by_name( name ).should_not == nil
			end

			it "should have a parent with name=#{name}" do
				Parent.find_by_name( name ).should_not == nil
			end

			let( :child ){ Child.find_by_name( name ) }
			it "should have the child and parent associated" do
				child.parent.should_not == nil
			end
			it "should have the child and parent similarly named" do
				child.parent.name.should == child.name
			end
		end
	end
=end

end
