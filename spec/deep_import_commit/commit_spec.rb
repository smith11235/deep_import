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

	DeepImport::Config.models.keys.each do |model_class|
		describe "#{model_class}" do
			it "should be no instances in the cache" do
				DeepImport::ModelsCache.cached_instances( model_class ).should have(0).items
			end
			it "should empty the cache for DeepImport#{model_class} as well" do
				DeepImport::ModelsCache.cached_instances( "DeepImport#{model_class}".constantize ).should have(0).items
			end

			it "should have #{expected_counts[model_class]} in the db" do
				model_class.count.should eq( expected_counts[model_class] )
			end

			it "should have all nil values for deep_import_id" do
				model_class.where( :deep_import_id => nil ).count.should eq(expected_counts[model_class])
			end

			describe "belongs to associations" do
				DeepImport::Config.models.each do |model_class,info|
					describe "for #{model_class}" do
						info[:belongs_to].each do |belongs_to_class|
							describe "=> #{belongs_to_class}" do
								let( :models ){ model_class.all }
								let( :belongs_to_models ){ belongs_to_class.all }
								let( :belongs_to_id_field ){"#{belongs_to_class.to_s.underscore}_id" }
								let( :belongs_to_reference_ids ){
									belongs_to_reference_ids = Hash.new
									model_class.group( belongs_to_id_field ).select( "#{belongs_to_id_field}, COUNT(id) AS num_belonging" ).each do |instance|
										belongs_to_reference_ids[ instance.send( belongs_to_id_field ) ] = instance.num_belonging
									end
									puts belongs_to_reference_ids.to_yaml
									belongs_to_reference_ids
								}
								let( :belongs_to_model_ids ){
									belongs_to_class.select( 'id' ).collect {|instance| instance.id }
								}

								it "should not have nil in the reference ids" do
									belongs_to_reference_ids.keys.should_not include(nil)
								end
								it "should have all the belongs_to model ids and no more" do
									belongs_to_reference_ids.keys.uniq.should =~ belongs_to_model_ids
								end
								it "should have the right counts for each reference id" do
									belongs_to_reference_ids.values.uniq.should == [2]
								end

								it "should have 1 belongs_to instance with the correct name for each source class" do

								end
							end
						end
					end
				end
			end
		end

	end
end
