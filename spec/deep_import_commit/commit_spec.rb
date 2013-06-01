require 'spec_helper'

describe "DeepImport::Commit" do
		before( :all ) do
			DeepImport::ModelsCache.clear
			# use the 'name' attribute as a second layer of validation for the 
			# deep_import id tracking
			(0..1).each do |parent_number|
				parent = Parent.new( :name => parent_number.to_s )
				(0..1).each do |child_number|
					child = parent.children.build( :name => "#{child_number},#{parent_number}" )
					(0..1).each do |grand_child_number|
						grandchild = child.grand_children.build( :name => "#{grand_child_number},#{child_number}" )
					end
				end
			end
			DeepImport.commit # save all models to database
		end

		expected_counts ||= { Parent => 2, Child => 4, GrandChild => 8 }

		it "should empty the cache" do
			DeepImport::Config.models.keys.each do |model_class|
				DeepImport::ModelsCache.cached_instances( model_class ).should have(0).items
				DeepImport::ModelsCache.cached_instances( "DeepImport#{model_class}".constantize ).should have(0).items
			end
		end


=begin
				- there should be X models in the db instead
				- no deep_import models
				- deep_import_id is null
				- with correct number of linkages
				- use names to ensure everyone is properly associated
=end
end
