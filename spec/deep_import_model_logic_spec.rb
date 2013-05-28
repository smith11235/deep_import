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
		# only test the root here as a basic sanity check
		root_class = DeepImport::Config.deep_import_config[:roots][0]
		root_instance = root_class.new
		it "should be the last instance in the cache" do
			DeepImport::ModelsCache.cached_instances( root_class ).last.should be(root_instance)
		end
	end

	describe "Model Tracking Blocks" do
		root_class = DeepImport::Config.deep_import_config[:roots][0]
		let( :model ) { # create with env var
		}
			# cache shouldnt grow
		let( :model2 ) { # create with deep_import_id => "dummy"
		}
			# cache shouldnt grow
		# save model, find it, cache shouldnt grow
	end
=begin
			- disabled testing:
				- does not run after_initialize
					- if env var set
						- new.save
					-	if not a new record
						- find the one we just made
					-	if deep_import_id is set
						- create with this set
					- cache does not grow

=end

end
