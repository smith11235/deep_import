require 'spec_helper'
require 'digest/md5'

describe "DB Setup" do
  # This tests configured, migrated, database

  let!(:conn) {ActiveRecord::Base.connection}

  def base_table_importable(table_name)
    # "has deep_import_id" 
    expect(conn.column_exists?(table_name, :deep_import_id, :string)).to be true
    # "has deep_import_id index" 
    index_name = "di_id_#{Digest::MD5.hexdigest(":#{table_name}")}"
    expect(conn.index_exists?(table_name, [:deep_import_id, :id], name: index_name)).to be true
  end

  def deep_table(table_name)
    # "has table" 
    expect(conn.table_exists?(table_name)).to be true
    # "has deep_import_id" do
    expect(conn.column_exists?(table_name, :deep_import_id, :string)).to be true
  end

  def deep_table_belongs(table_name, reference)
    association_field = "deep_import_#{reference}_id".to_sym
    # "has reference field"
    expect(conn.column_exists?(table_name, association_field, :string)).to be true
    # "has index for reference" 
    # TODO: remove refernece from name
    index_name = "di_#{reference}_#{Digest::MD5.hexdigest( ":#{table_name}_#{reference}" )}"
    expect(conn.index_exists?(table_name, [:deep_import_id, association_field], name: index_name)).to be true
  end


  describe "importable model setup" do
    it "parents" do
      base_table_importable("parents")
    end
    it "children" do
      base_table_importable("children")
    end
    it "grand_children" do
      base_table_importable("grand_children")
    end
  end

  describe "deep import model tables" do
    it "Child" do
      deep_table("deep_import_children")
      deep_table_belongs("deep_import_children", "parent")
    end
    it "GrandChild" do
      deep_table("deep_import_grand_children")
      deep_table_belongs("deep_import_grand_children", "child")
    end

    describe "InLaws Polymorphic Relation" do
      it "has two reference fields, and 2 indexes"
    end
  end
end
