require 'spec_helper'

describe "DeepImport.commit!" do

	before(:each) {
		DeepImport.import do
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

	describe "Base Model Tracking" do
    it "tracks inlaws/polymorphism"

		it "2 parents in it named a and b" do
			expect(Parent.pluck(:name)).to match_array(%w(a b))
		end
		it "4 children in it named a, a, b, b" do
		  expect(Child.pluck(:name)).to match_array(%w(a a b b))
		end
		it "8 grand_children in it named a, a, a, a, b, b, b, b" do
		  expect(GrandChild.pluck(:name)).to match_array(%w(a a a a b b b b))
		end
    describe "correctly associated" do
      it "has no missing relations" do
        expect(Child.where(parent_id: nil).exists?).to be false
        expect(GrandChild.where(child_id: nil).exists?).to be false
      end

      it "names familes the same" do
        expect(Child.joins(:parent).where("children.name != parents.name").exists?).to be false
        expect(GrandChild.joins(:child).where("grand_children.name != children.name").exists?).to be false
      end
    end
	end

	describe "Post-Commit Cleanup" do
		it "empties the models_cache" do
      pending
      # TODO: reset at end of import?
			expect(DeepImport::ModelsCache.empty?).to be true
		end

    describe "removes deep import models" do
  		it "DeepImportParent" do
  			expect(DeepImportParent.count).to eq(0)
  		end
  		it "DeepImportChild" do
  			expect(DeepImportChild.count).to eq(0)
  		end
  		it "DeepImportGrandChild" do
  			expect(DeepImportGrandChild.count).to eq(0)
  		end
    end

    describe "removes deep import ids" do
  		it "on Parent" do
  			expect(Parent.where.not(deep_import_id: nil).exists?).to be false
  		end
  		it "on Child" do
  			expect(Child.where.not(deep_import_id: nil).exists?).to be false
  		end
  		it "on GrandChild" do
  			expect(GrandChild.where.not(deep_import_id: nil).exists?).to be false
  		end
    end

	end

end
