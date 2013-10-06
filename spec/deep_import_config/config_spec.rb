require 'spec_helper'

describe "DeepImport::Config" do

	describe "General Api" do
		describe "Included Models" do
			[Parent,Child,GrandChild].each do |member|
				it "has #{member}" do
					DeepImport::Config.models.should include(member)
				end
				{ :flags => Hash, :belongs_to => Array, :has_one => Array, :has_many => Array }.each do |component,type|
					it "has a #{component} of type #{type}" do
						DeepImport::Config.models[ member ].should have_key(component)
						DeepImport::Config.models[ member ][component].should be_instance_of(type)
					end
				end
			end
		end

	end

	describe "Detailed" do
		config = DeepImport::Config.deep_import_config
		# => { :models => Hash.new, :roots => Array.new, :parent_class_of => Hash.new }
		describe "Components" do
			{:models => Hash, :roots => Array, :parent_class_of => Hash }.each do |component,type|
				it "has a #{component} of type #{type}" do
					config.should have_key component
					config[component].should be_instance_of(type)
				end
			end
		end

		describe "Roots" do
			it "has a Parent as the only root" do
				config[:roots].size.should be(1)
				config[:roots][0].should be(Parent)
			end
		end

		# test has_many/has_one/belongs_to
		{ 
			:has_many => {Parent => [Child], Child => [GrandChild], GrandChild => []},
			:has_one => {Parent => [], Child => [], GrandChild => []},
			:belongs_to => {Parent => [], Child => [Parent], GrandChild => [Child]}
		}.each do |association_type,model_map|
			describe "#{association_type.to_s.titleize} Associations Of" do
				model_map.each do |model,associations|
					actual_associations = config[:models][model][association_type]
					describe "#{model}" do
						it "has #{associations.size} of an expected #{actual_associations.size}" do
							actual_associations.size.should eq(associations.size)
						end
						associations.each do |association|
							it "includes #{association}" do
								actual_associations.should include(association)
							end
						end
					end
				end
			end
		end

	end
end
