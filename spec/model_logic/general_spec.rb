require 'spec_helper'
# TODO: remove/deprecated

describe 'DeepImport::ModelLogic (on Child)' do
  let(:error_msg){
    "DeepImport: commit method called within import block - change code or pass 'on_save: :noop'"
  }
  describe "Polymorphic Belongs To" do
    it "creates normally if not importing" do
      p = Parent.create!
      p.in_laws.create!
      c = Child.create!
      InLaw.new(relation: c).save!
      expect(InLaw.count).to eq(2)
      expect(InLaw.where(relation_id: nil).count).to eq(0)
      expect(InLaw.pluck(:relation_type).uniq.compact.size).to eq(2)
    end
    describe "Importing" do
      # TODO: has_many vs has_one relationship

      it "tracks type and id" do
        DeepImport.import do
          puts "Importing"
          parent = Parent.new 
          parent.in_laws.build name: :parent_marriage
          child = Child.new
          child.in_laws.build name: :child_marriage
          expect(InLaw.count).to eq(0)

          gc = GrandChild.new
          InLaw.new name: :grand_child_marriage, relation: gc

          expect(InLaw.count).to eq(0)
          puts "Import block done"
          # TODO: could test model cache
        end
        # InLaws created
        expect(InLaw.count).to eq(3)
        # with Relations set correctly
        expect(InLaw.where(relation_id: nil).count).to eq(0)
        expect(InLaw.pluck(:relation_type).uniq.compact.size).to eq(3)

        expect(Parent.first.in_laws.first.name).to eq('parent_marriage')
        expect(Child.first.in_laws.first.name).to eq('child_marriage')
        expect(GrandChild.first.in_laws.first.name).to eq('grand_child_marriage')
      end
    end
  end
end
