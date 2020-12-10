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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_10_170122) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "children", force: :cascade do |t|
    t.string "name"
    t.json "data"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "deep_import_id"
    t.index ["deep_import_id", "id"], name: "di_id_cd32b2089b38315267372441b14914ac"
    t.index ["parent_id"], name: "index_children_on_parent_id"
  end

  create_table "deep_import_children", force: :cascade do |t|
    t.string "deep_import_id"
    t.datetime "parsed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "deep_import_parent_id"
    t.index ["deep_import_id", "deep_import_parent_id"], name: "di_parent_5398201a25d34aa77ba2aad1ab1114c6"
  end

  create_table "deep_import_grand_children", force: :cascade do |t|
    t.string "deep_import_id"
    t.datetime "parsed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "deep_import_child_id"
    t.index ["deep_import_id", "deep_import_child_id"], name: "di_child_68c870732d51b24b0fa476536d9b20d4"
  end

  create_table "deep_import_parents", force: :cascade do |t|
    t.string "deep_import_id"
    t.datetime "parsed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grand_children", force: :cascade do |t|
    t.string "name"
    t.bigint "child_id"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "deep_import_id"
    t.index ["child_id"], name: "index_grand_children_on_child_id"
    t.index ["deep_import_id", "id"], name: "di_id_4b28a2b058ab07f15071d1402d5590e0"
  end

  create_table "in_laws", force: :cascade do |t|
    t.string "name"
    t.json "data"
    t.string "parent_type"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_type", "parent_id"], name: "index_in_laws_on_parent_type_and_parent_id"
  end

  create_table "parents", force: :cascade do |t|
    t.string "name"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "deep_import_id"
    t.index ["deep_import_id", "id"], name: "di_id_9292d84064b4ffecb3d5a9878f5fdeb8"
  end

  add_foreign_key "children", "parents"
  add_foreign_key "grand_children", "children"
end