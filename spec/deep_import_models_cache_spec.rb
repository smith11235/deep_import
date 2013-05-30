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

	describe "Model Creation Tracking" do
		before( :all ) do
			DeepImport::ModelsCache.clear
			(0..1).each do
				parent = Parent.new
				(0..1).each do
					child = parent.children.build
					(0..1).each do
						grandchild = child.grandchildren.build
					end
				end
			end
			#- assign values such that we know who the parent should be
			#	- Child.name = "parent=X"
		end

		# let:
		# - collect array of source deep import id's
		# - collect array of deep_import_* depe_import_ids
		let( :expected_counts ){ { Parent => 2, Child => 4, GrandChild => 8 } }
		descibe "expected model counts" do
			expected_counts.each do |model_class,expected_count|
		# it:
		# - models should all have deep_import_id set 
		# - ** nil not a member
		# - ** count of id's = expected count
				it "should have #{expected_count} #{model_class.to_s.pluralize}" do
				end
				it "should have #{expected_count} DeepImport#{model_class.to_s.pluralize}" do
				end
		# - should be 1 and only 1 deep_import_model with that id
		# - ** deep_import_id's should be unique (.uniq.size = .size)
		# - source and deep import id's should be aligned

			end
		end

		# - check all associations using audit trail
		# - run clear, size back to 0
	end
end
