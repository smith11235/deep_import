# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131030034726) do

  create_table "children", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "deep_import_id"
  end

  add_index "children", ["deep_import_id", "id"], :name => "di_id_index"
  add_index "children", ["parent_id"], :name => "index_children_on_parent_id"

  create_table "deep_import_children", :force => true do |t|
    t.string   "deep_import_id"
    t.datetime "parsed_at"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "deep_import_parent_id"
  end

  add_index "deep_import_children", ["deep_import_id", "deep_import_parent_id"], :name => "di_parent"

  create_table "deep_import_grand_children", :force => true do |t|
    t.string   "deep_import_id"
    t.datetime "parsed_at"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "deep_import_child_id"
  end

  add_index "deep_import_grand_children", ["deep_import_id", "deep_import_child_id"], :name => "di_child"

  create_table "deep_import_parents", :force => true do |t|
    t.string   "deep_import_id"
    t.datetime "parsed_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "grand_children", :force => true do |t|
    t.integer  "child_id"
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "deep_import_id"
  end

  add_index "grand_children", ["child_id"], :name => "index_grand_children_on_child_id"
  add_index "grand_children", ["deep_import_id", "id"], :name => "di_id_index"

  create_table "parents", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "deep_import_id"
  end

  add_index "parents", ["deep_import_id", "id"], :name => "di_id_index"

end
