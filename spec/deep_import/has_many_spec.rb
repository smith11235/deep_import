require 'spec_helper'

describe "HasMany" do
  let(:error_msg){
    "DeepImport: commit method called within import block - change code or pass 'on_save: :noop'"
  }

  describe "normal execution" do
    it "ignores tracking" do
      p = Parent.new
      c = p.children.new
      expect(c.deep_import_id).to be_nil
    end
    it "allows save/create" do
      p = Parent.new
      p.save
      p.children.create!
    end
  end

  describe "import execution" do
    it "tracks associated models" do
      DeepImport.import do 
        p = Parent.new 
        p.children.build
        p.children.build
        # Child.new(parent: p) # this is belongs_to
      end
      expect(Parent.count).to eq(1)
      expect(Child.count).to eq(2)
      expect(Parent.first.children.count).to eq(2)
    end

    it "blocks saves (creates) by default" do
      expect { 
        DeepImport.import do 
          p = Parent.new 
          p.children.create
        end
      }.to raise_error(error_msg)
      DeepImport.reset!
      expect { 
        DeepImport.import do 
          p = Parent.new 
          p.children.create!
        end
      }.to raise_error(error_msg)
      expect(Parent.count).to eq(0)
      expect(Child.count).to eq(0)
    end

    it "ignores saves if option set" do 
      DeepImport.import on_save: :noop do 
        p = Parent.new
        expect { 
          p.children.create
        }.to_not raise_error
        expect { 
          p.children.create!
        }.to_not raise_error
        expect(Parent.count).to eq(0)
        expect(Child.count).to eq(0)
      end
      expect(Parent.count).to eq(1)
      expect(Child.count).to eq(2)
      expect(Parent.first.children.count).to eq(2)
    end
  end
end
