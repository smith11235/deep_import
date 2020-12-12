require 'spec_helper'

describe "Importable" do
  let(:error_msg){
    "DeepImport: commit method called within import block - change code or pass 'on_save: :noop'"
  }
  before :each do 
    DeepImport.reset!
  end

  describe "allow_commit?" do
    it "true" 
    it "false"
    it "error"
  end

  it "adds after initialize tracking" do
    expect_any_instance_of(Parent).to receive(:deep_import_after_initialize_add_to_cache)
    Parent.new
  end

  it "prepends Saveable module"

  describe "normal execution" do
    it "ignores tracking" do
      expect(DeepImport::ModelsCache.empty?).to be true
      p = Parent.new
      expect(p.deep_import_id).to be_nil
      expect(DeepImport::ModelsCache.empty?).to be true
    end

    it "allows saves" do
      Parent.new.save
      Parent.new.save!
      expect(Parent.count).to eq(2)
    end
  end

  describe "import execution" do
    it "tracks model after initialization" do
      DeepImport.import do
        p = Parent.new
        expect(DeepImport::ModelsCache.empty?).to be false
        expect(p.deep_import_id).to_not be_nil
      end
      expect(Parent.count).to eq(1)
    end

    it "blocks saves by default" do
      expect {
        DeepImport.import do
          Parent.new.save
        end
      }.to raise_error(error_msg)
      DeepImport.reset!
      expect {
        DeepImport.import do
          Parent.new.save!
        end
      }.to raise_error(error_msg)

      expect(Parent.count).to eq(0)
    end

    it "no-ops saves if option set" do
      DeepImport.import on_save: :noop do 
        expect { Parent.new.save }.to_not raise_error
        expect { Parent.new.save! }.to_not raise_error
        expect(Parent.count).to eq(0)
      end
      expect(Parent.count).to eq(2)

    end
  end
end
