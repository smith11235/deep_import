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

=begin
			- disabled testing:
				- does not run after_initialize
					- if env var set
					-	if not a new record
					-	if deep_import_id is set
					- cache does not grow

			- for root only:
				- cache is tracking this model
					- let model.new
					- DeepImport::ModelsCache.cached_instances( model_class ) #=> array of instances
					- size = 1
					- [0] == model_instance

=end
		end
	end

end
