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

			it "has accessible deep_import_id"	do
				model_class.accessible_attributes.should include( :deep_import_id )
			end

			it "has :deep_import_after_initialize method" do
				model_instance.should be_respond_to :deep_import_after_initialize
			end

			it "is tracked by model cache" do
				DeepImport::ModelsCache.cached_instances( model_class ).should be_an_instance_of( Array )
			end

			%w( belongs_to has_one ).each do |association_type|
				describe association_type do
					# currently disabled
					it "should prevent create_other"
					it "should prevent create_other!"
					# enabled
					it "should override other=" # tags correct model with ownership
					it "should override build" # creates model with attributes, tagged with ownership
				end
			end

		end
	end

	def set_env( var, value = nil, &block )
		var = var.to_s
		original_value = ENV[var]
		ENV[var] = ( value.nil? ? nil : value.to_s )
		rval = block.call
		ENV[var] = original_value
		rval # return the block result
	end


	describe "Creation Tracking" do
		let( :root_class ){ DeepImport::Config.deep_import_config[:roots][0] }

		it "should be in the cache" do
			tracked_model = root_class.new 
			DeepImport::ModelsCache.cached_instances( root_class ).last.should be(tracked_model)
		end

		it "shouldnt add to the cache when found" do
			# after_initialize is called after new and find
			saved_model = root_class.create # load it, set the id
			size_before_find = DeepImport::ModelsCache.cached_instances( root_class ).size
			found_model = root_class.find( saved_model.id )
			DeepImport::ModelsCache.cached_instances( root_class ).size.should eq( size_before_find )
		end

		it "environmental disabling should block the queue" do
			untracked_env_model = set_env("disable_deep_import", "disabled") { root_class.new }
			DeepImport::ModelsCache.cached_instances( root_class ).should_not include(untracked_env_model)
		end

		it "preexisting import id blocks the queue" do
			preexisting_id_model = root_class.new( :deep_import_id => "test_id" ) 
			DeepImport::ModelsCache.cached_instances( root_class ).should_not include(preexisting_id_model)
		end
	end

end
