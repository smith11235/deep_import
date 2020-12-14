require 'spec_helper'

describe "BelongsTo" do
  let(:error_msg){
    "DeepImport: commit method called within import block - change code or pass 'on_save: :noop'"
  }

  describe "normal execution" do
    it "ignores tracking" do
      child = Child.new
      child.build_parent
      expect(child.parent.deep_import_id).to be_nil
    end

    it "allows saves" do
      ['', '!'].each do |ending|
        child = Child.new
        child.save!
        child.send("create_parent#{ending}")
      end
      expect(Parent.count).to eq(2)
    end
  end

  describe "import execution" do
    it "tracks model from initialization" do
      DeepImport.import do
        Child.new(parent: Parent.new)
  
        c = Child.new
        c.build_parent
  
        c = Child.new
        c.parent = Parent.new
      end
      expect(Parent.count).to eq(3)
      expect(Child.count).to eq(3)
      expect(Child.where(parent: nil).count).to eq(0)
      expect(Child.pluck(:parent_id).uniq.size).to eq(3)
    end

    it "blocks saves by default" do
      expect { 
        DeepImport.import do 
          c = Child.new 
          c.create_parent
        end
      }.to raise_error(error_msg)
      DeepImport.reset!
      expect { 
        DeepImport.import do 
          c = Child.new 
          c.create_parent!
        end
      }.to raise_error(error_msg)
      expect(Child.count).to eq(0)
      expect(Parent.count).to eq(0)
    end
    it "ignores saves if option set" do
      DeepImport.import on_save: :noop do 
        expect { 
          c = Child.new 
          c.create_parent
        }.to_not raise_error
        expect { 
          c = Child.new
          c.create_parent!
        }.to_not raise_error
        expect(Child.count).to eq(0)
        expect(Parent.count).to eq(0)
      end
      expect(Child.count).to eq(2)
      expect(Parent.count).to eq(2)
    end
  end
end
