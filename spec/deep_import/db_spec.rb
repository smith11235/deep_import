require 'spec_helper'
require 'digest/md5'

describe "DB Setup" do
  # This tests configured, migrated, database

  describe "changes for: parents" do
    let( :table_name ) { "parents" }	
    it "should have parents.deep_import_id column" do
      ActiveRecord::Base.connection.should be_column_exists( table_name, :deep_import_id, :string )
    end
    let( :index_name ) { "di_id_#{Digest::MD5.hexdigest(':parents')}" }
    it "should have an index on parents.deep_import_id" do
      ActiveRecord::Base.connection.should be_index_exists( table_name, [:deep_import_id, :id], :name => index_name )
    end
  end

  describe "changes for: children" do
    let( :table_name ){ "children"	}
    it "should have children.deep_import_id column" do
      ActiveRecord::Base.connection.should be_column_exists( table_name, :deep_import_id, :string )
    end
    let( :index_name ) { "di_id_#{Digest::MD5.hexdigest(':children')}" }
    it "should have an index on children.deep_import_id" do
      ActiveRecord::Base.connection.should be_index_exists( table_name.to_sym, [:deep_import_id, :id], :name => index_name )
    end
  end
  describe "changes for: grand_children" do
    let( :table_name ){ "grand_children"	}
    it "should have grand_children.deep_import_id column" do
      ActiveRecord::Base.connection.should be_column_exists( table_name, :deep_import_id, :string )
    end
    let( :index_name ) { "di_id_#{Digest::MD5.hexdigest(':grand_children')}" }
    it "should have an index on grand_children.deep_import_id" do
      ActiveRecord::Base.connection.should be_index_exists( table_name, [:deep_import_id, :id], :name => index_name )
    end
  end

  model_class = Child 
  describe "Generated Model: DeepImport#{model_class}" do
    let( :deep_model_class ){ "DeepImport#{model_class}".constantize }
    it "should expose deep_import_id" do
      deep_model_class.column_names.should include( 'deep_import_id' )
    end
    let( :deep_model_table ){ "DeepImport#{model_class}".tableize }
    it "should have a table" do
      ActiveRecord::Base.connection.should be_table_exists( deep_model_table )
    end
    it "should have a 'deep_import_id' column in it's table" do
      ActiveRecord::Base.connection.should be_column_exists( deep_model_table, :deep_import_id, :string )
    end
    describe "tracks #{Parent}" do
      let( :deep_model_class ){ "DeepImport#{model_class}".constantize }
      let( :association_field ){ "deep_import_#{Parent.to_s.underscore}_id".to_sym }
      it "should have a reference field in it's table" do
        ActiveRecord::Base.connection.should be_column_exists( deep_model_table, association_field, :string )
      end

      let( :index_name ){ 
        hash_of_source_target = Digest::MD5.hexdigest( ":deep_import_children_parent" )
        "di_parent_#{hash_of_source_target}"
      }

      it "should have an index for this reference in it's table" do
        ActiveRecord::Base.connection.should be_index_exists( deep_model_table, [:deep_import_id, association_field], :name => index_name )
      end

      it "should expose this reference field to it's model class" do
        deep_model_class.column_names.should include( association_field.to_s )
      end

    end
  end

  describe "Generated Model: DeepImport#{GrandChild}" do
    let( :deep_model_class ){ "DeepImportGrandChild".constantize }
    it "should expose deep_import_id" do
      deep_model_class.column_names.should include( 'deep_import_id' )
    end
    let( :deep_model_table ){ "DeepImport#{GrandChild}".tableize }
    it "should have a table" do
      ActiveRecord::Base.connection.should be_table_exists( deep_model_table )
    end
    it "should have a 'deep_import_id' column in it's table" do
      ActiveRecord::Base.connection.should be_column_exists( deep_model_table, :deep_import_id, :string )
    end


    describe "tracks Child" do
      let( :association_field ){ "deep_import_#{Child.to_s.underscore}_id".to_sym }
      it "should have a reference field in it's table" do
        ActiveRecord::Base.connection.should be_column_exists( deep_model_table, association_field, :string )
      end
      let( :index_name ){ 
        hash_of_source_target = Digest::MD5.hexdigest( ":deep_import_grand_children_child" )
        "di_child_#{hash_of_source_target}"
      }
      it "should have an index for this reference in it's table" do
        ActiveRecord::Base.connection.should be_index_exists( deep_model_table, [:deep_import_id, association_field], :name => index_name )
      end
    end
  end
end
