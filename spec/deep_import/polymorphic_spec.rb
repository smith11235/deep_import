require 'spec_helper'

describe "Polymorphic Association" do
  it "handles multiple polymorphic belongs to successfully"

  # Note/FYI: 3 ways to create polymorphic instance

  it "creates instances normally if not importing" do
    p = Parent.create!
    p.in_laws.create!

    c = Child.create!
    InLaw.new(relation: c).save!

    gc = GrandChild.create!
    il = InLaw.new
    il.relation = gc
    il.save!

    expect(InLaw.count).to eq(3)
    expect(InLaw.where(relation_id: nil).count).to eq(0)
    expect(InLaw.pluck(:relation_type).uniq.compact.size).to eq(3)
  end

  describe "tracks id + type on" do
    it "has_many build helper" do
      DeepImport.import do
        parent = Parent.new 
        parent.in_laws.build 
      end
      expect(InLaw.count).to eq(1)
      expect(InLaw.first.relation_type).to eq("Parent")
      expect(InLaw.first.relation).to_not be_nil
      expect(Parent.first.in_laws.count).to eq(1)
    end

    it "belongs_to assignment helper" do
      DeepImport.import do
        child = Child.new
        il = InLaw.new
        il.relation = child 
      end

      expect(InLaw.count).to eq(1)
      expect(InLaw.first.relation_type).to eq("Child")
      expect(InLaw.first.relation).to_not be_nil
      expect(Child.first.in_laws.count).to eq(1)
    end

    it "after_init belongs_to helper" do
      DeepImport.import do
        gc = GrandChild.new
        InLaw.new name: :grand_child_marriage, relation: gc # belongs_to after-init 
        expect(InLaw.count).to eq(0)
      end

      expect(InLaw.count).to eq(1)
      expect(InLaw.first.relation_type).to eq("GrandChild")
      expect(InLaw.first.relation).to_not be_nil
      expect(GrandChild.first.in_laws.count).to eq(1)
    end
  end
end