require 'spec_helper'

describe "DeepImport::ModelLogic" do


	DeepImport::Config.models.keys.each do |model_class|
		describe "Changes To: #{model_class}" do

			let( :model_instance ) { 
				ENV["disable_deep_import"] = "disabled" # we dont want to run deep_import logic yet
				model_instance = model_class.new 
				ENV["disable_deep_import"] = nil 
				model_instance 
			} 

			it "reports the same parent as the config" do
				model_class.parent_class.should be(DeepImport::Config.parent_class_of( model_class ))
			end

			it "has accessible deep_import_id"	do
				model_class.accessible_attributes.should include( :deep_import_id )
			end

			it "has :deep_import_after_initialize method" do
				model_instance.should be_respond_to :deep_import_after_initialize
			end

			it "is tracked by model cache" do
				DeepImport::ModelsCache.cached_instances( model_class ).should be_an_instance_of( Array )
			end
		end
	end

	describe "Model creation tracking" do
		let( :root_class ){ DeepImport::Config.deep_import_config[:roots][0] }
		describe "should save" do
			# only test the root here as a basic sanity check
			it "should be the last instance in the cache" do
				root_instance = root_class.new #after creation
				DeepImport::ModelsCache.cached_instances( root_class ).last.should be(root_instance)
			end
		end

		describe "should not save" do
			it "environmental disabling should block the queue" do
				ENV["disable_deep_import"] = "disabled"
				env_model = root_class.new 
				ENV["disable_deep_import"] = nil
				DeepImport::ModelsCache.cached_instances( root_class ).should_not include(env_model)
			end

			it "preexisting import id blocks the queue" do
				preexisting_model = root_class.new( :deep_import_id => "test id" )
				DeepImport::ModelsCache.cached_instances( root_class ).should_not include(preexisting_model)
			end
		end
	end

=begin
			- disabled testing:
					-	if not a new record
						- find the one we just made
					- cache does not grow

=end

end
