require 'spec_helper'

describe "DeepImport.commit!" do
	# basically going to check that the resultant models are all aligned correctly
	# this is not super granular to commit as it is relying on import/models_cache, etc

	before(:all) {
		delete_models # Needed? should be automatic
		DeepImport.import reset: true do
			%w(a b).each do |parent_name|
				parent = Parent.new name: parent_name
				(0..1).each do |child_number|
					child = parent.children.build name: parent_name #[parent_name, child_number].join("+")
					(0..1).each do |grand_child_number|
						grand_child = child.grand_children.build name: parent_name #[parent_name, child_number, grand_child_number].join("+")
					end
				end
			end
		end
	}

	after(:all){
		delete_models # TODO: remove 
	}

	describe "Base Model Tracking" do

		it "should have 2 parents in it named a and b" do
			Parent.pluck(:name).should =~ %w(a b)
		end
		it "should have 4 children in it named a, a, b, b" do
		  Child.pluck(:name).should =~ %w(a a b b)
		end
		it "should have 8 grand_children in it named a, a, a, a, b, b, b, b" do
		  GrandChild.pluck(:name).should =~ %w(a a a a b b b b)
		end

	end

	describe "Post-Commit Cleanup" do
		it "should empty the models_cache" do
			DeepImport::ModelsCache.empty?
		end

		it "should have 0 DeepImportParent's" do
			DeepImportParent.count.should == 0
		end
		it "should have 0 DeepImportChild's" do
			DeepImportChild.count.should == 0
		end
		it "should have 0 DeepImportGrandChild's" do
			DeepImportGrandChild.count.should == 0
		end

		it "should set deep_import_id's to nil on Parent" do
			Parent.pluck( :deep_import_id ).uniq.should =~ [nil]
		end
		it "should set deep_import_id's to nil on Child" do
			Child.pluck( :deep_import_id ).uniq.should =~ [nil]
		end
		it "should set deep_import_id's to nil on GrandChild" do
			GrandChild.pluck( :deep_import_id ).uniq.should =~ [nil]
		end


	end

	describe "Association tracking" do
		describe "Child.belongs_to Parent" do
			let( :parent_distribution ) {
				dist = Hash.new
				Child.joins( :parent ).group( "parents.id" ).select( "MAX(parents.name) AS parent_name, count(children.id) AS child_references" ).each do |parent_reference|
					dist[ parent_reference.parent_name ] = parent_reference.child_references.to_s
				end
				dist
			}

			it "should have 2 distinct parents a and b" do
				parent_distribution.keys.should =~ %w(a b)
			end

			it "should have parents each occuring twice" do
				parent_distribution.values.should =~ %w(2 2)
			end
		end

		describe "GrandChild.belongs_to Child" do

			let( :child_references ) {
				reference_counts = GrandChild.joins( :child ).group( "children.id, children.name" ).select( "MAX(children.name) AS child_name, count(grand_children.id) AS grand_child_references" )
				# now reformat it to an array
				info = { :names => nil, :counts => nil }
				info[ :names ] = reference_counts.collect {|reference| reference.child_name }
				info[ :counts ] = reference_counts.collect {|reference| reference.grand_child_references.to_s }
				info
			}

			it "should have 4 distinct children a, a, b, b" do
				child_references[:names].should =~ %w(a a b b)
			end

			it "should have parents each occuring twice" do
				child_references[:counts].should =~ %w(2 2 2 2)
			end
		end
	end
end
