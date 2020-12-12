require 'spec_helper'

describe "Migration", migration: true do

  def tmp_root!
    ENV["DB_ROOT_PATH"] = "tmp"
  end

  def reset
    ENV["DB_ROOT_PATH"] = nil
    FileUtils.rm_f Dir.glob("tmp/migrate/*")
  end

  before :each do
    reset
  end
  after :each do
    reset
  end

  describe "helper_methods" do
    describe "current_file" do
      it "finds default spec file" do
        f = DeepImport::Migration.current_file
        expect(f).to_not be_nil
        expect(f).to include(DeepImport::MIGRATION_NAME.underscore)
      end
      it "finds nothing if no file present" do
        tmp_root!
        expect(DeepImport::Migration.current_file).to be_nil
      end
    end

    it "migration_version" do
      v = DeepImport::Migration.migration_version
      expect(v).to_not be_nil
      expect(v).to match(/\d{14}/)
    end
  end

  describe "create_file" do
    it "fails if file already present" do
      # spec/support/db/migrate/* is already setup
      expect{DeepImport::Migration.create_file}.to raise_error("DeepImport: Migration already exists.")
    end

    it "succeeds setting up each required component" do
      tmp_root!
      expect {DeepImport::Migration.create_file}.to_not raise_error
      expect(DeepImport::Migration.current_file).to_not be_nil
      # TODO: add detailed checks
      # - each base class has 
      #   - deep_import_id
      #   - index
      # - each deep import class (parent, child, grandchild, in_law)
      #   - has deep_import_id
      #   - belongs_to fields
      #   - index
    end
  end

  describe "remove_file" do
    describe "fails if" do
      # TODO: add error messages
      # Default execution assumes db is setup and migrated
      it "no file present" do
        tmp_root!
        expect{DeepImport::Migration.remove_file}.to raise_error("DeepImport: No migration file to remove (in: tmp/migrate)")
      end
      it "still loaded in db" # TODO
      it "still loaded in db/schema" do
        expect{DeepImport::Migration.remove_file}.to raise_error("DeepImport: Schema changes still in DB, cannot remove migration file (spec/support/db/schema.rb)")
      end
    end

    it "removes file" do
      tmp_root!
      # Prep Setup - Tested above in detail
      expect(DeepImport::Migration.current_file).to be_nil
      DeepImport::Migration.create_file 
      expect(DeepImport::Migration.current_file).to_not be_nil
      # Actual teardown test
      expect{DeepImport::Migration.remove_file}.to_not raise_error
      expect(DeepImport::Migration.current_file).to be_nil
    end
  end

end
