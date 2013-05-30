require 'spec_helper'

describe "DeepImport::ModelsCache" do

	it "should be initialized" do
		DeepImport::ModelsCache.get_cache.should be_an_instance_of( Hash )
	end

	describe "tracked models" do
		DeepImport::Config.models.keys.each do |model_class|
			it "should have #{model_class} in cache" do
				DeepImport::ModelsCache.cached_instances( model_class ).should be_an_instance_of( Array )
			end
			it "should have DeepImport#{model_class} in cache" do
				DeepImport::ModelsCache.cached_instances( "DeepImport#{model_class}".constantize ).should be_an_instance_of( Array )
			end
		end
	end

=begin
	describe "Model Creation Tracking" do
	-	cache: 
		- let:
			- cache.clear
			- add 2 x 2 x 2 of parent child grand_child 
			- assign values such that we know who the parent should be
				- Child.name = "parent=X"
		- should be 2, 4, 8 instances in cache
		- should be equal numbers of source and deep import models
		- check all associations using audit trail
	end
=end
end
