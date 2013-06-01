require 'spec_helper'

describe "DeepImport::ModelsCache" do

	it "should be initialized" do
		DeepImport::ModelsCache.get_cache.should be_an_instance_of( Hash )
	end

	it "should be clearable" do
		root_class = DeepImport::Config.deep_import_config[:roots][0]
		root_class.new # create a root instance, should be in cache
		DeepImport::ModelsCache.clear
		DeepImport::Config.models.keys.each do |model_class|
			DeepImport::ModelsCache.cached_instances( model_class ).should have(0).items
			DeepImport::ModelsCache.cached_instances( "DeepImport#{model_class}".constantize ).should have(0).items
		end
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

	describe "Model Creation Tracking" do
		before( :all ) do
			DeepImport::ModelsCache.clear
			(0..1).each do
				parent = Parent.new
				(0..1).each do
					child = parent.children.build
					(0..1).each do
						grandchild = child.grand_children.build
					end
				end
			end
		end

		expected_counts ||= { Parent => 2, Child => 4, GrandChild => 8 }

		describe "expected model ids for" do
			expected_counts.each do |model_class,expected_count|
				describe "#{model_class}" do
					let( :model_ids ){ 
						models = DeepImport::ModelsCache.cached_instances( model_class )
						models.collect {|instance| instance.deep_import_id } 
					}
					let( :deep_model_ids ){ 
						deep_models = DeepImport::ModelsCache.cached_instances( "DeepImport#{model_class}".constantize )
						deep_models.collect {|instance| instance.deep_import_id } 
					}

					it "should have set deep_import_id's on all source model instances" do
						model_ids.should_not include(nil)
						deep_model_ids.should_not include(nil)
					end

					it "should have the right number of ids" do
						model_ids.should have(expected_count).items
						deep_model_ids.should have(expected_count).items
					end

					it "should have source and deep import id's in alignment" do
						model_ids.should == deep_model_ids
						# verifies both members and ordering
					end

					it "should have all unique deep_import_ids" do
						model_ids.uniq.should have(expected_count).items
					end

					it "should have validly formatted deep_import_id's"

				end
			end

		end

		describe "belongs_to associations" do
			DeepImport::Config.models.each do |model_class,info|
				describe "for #{model_class}" do
					info[:belongs_to].each do |belongs_to_class|
						let( :belongs_to_reference_ids ){
							belongs_to_reference_ids = Hash.new
							DeepImport::ModelsCache.cached_instances( "DeepImport#{model_class}".constantize ).each {|instance| 
								belongs_to_reference_ids[instance.send( "deep_import_#{belongs_to_class.to_s.underscore}_id" )] ||= 0
								belongs_to_reference_ids[instance.send( "deep_import_#{belongs_to_class.to_s.underscore}_id" )] += 1
							}
							belongs_to_reference_ids
						}
						let( :belongs_to_model_ids ){
							DeepImport::ModelsCache.cached_instances( belongs_to_class ).collect {|instance| instance.deep_import_id}
						}
						it "should not have nil in the reference ids" do
							belongs_to_reference_ids.keys.should_not include(nil)
						end
						it "should have all the belongs_to model ids and no more" do
							belongs_to_model_ids.should == belongs_to_reference_ids.keys.uniq 
						end
						it "should have the right counts for each reference id" do
							belongs_to_reference_ids.values.uniq.should == [2]
						end
					end
				end
			end
		end

		it "should have strictly validated belongs_to associations"
		# ensure the name= values on the models match up logically
	end
end
