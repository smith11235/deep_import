require 'spec_helper'

describe "DeepImport::Config" do

	describe "General Api" do
		describe "Included Models" do
			[Parent,Child,GrandChild].each do |member|
				it "has #{member}" do
					DeepImport::Config.models.keys.include?(member).should be(true)
				end
			end
		end

		describe "Parents of Models" do
			{Parent => nil,Child => Parent,GrandChild => Child}.each do |member,expected_parent|
				describe "Parent of: #{member}" do
					it "has a parent of #{expected_parent}" do
						DeepImport::Config.parent_class_of( member ).should be(expected_parent)
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
					describe "#{model}" do
						it "has #{associations.size} of an expected #{config[:models][model][association_type].size}" do
							config[:models][model][association_type].size.should eq(associations.size)
						end
					end
				end
			end
		end

	end
end
