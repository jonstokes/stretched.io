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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150806155547) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "document_adapters", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",               null: false
    t.uuid     "document_schema_id", null: false
    t.uuid     "document_queue_id",  null: false
    t.uuid     "template_id"
    t.string   "xpath"
    t.json     "property_queries",   null: false
    t.text     "scripts",                         array: true
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "document_adapters", ["name"], name: "index_document_adapters_on_name", using: :btree

  create_table "document_queues", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",          null: false
    t.uuid     "rate_limit_id", null: false
    t.integer  "max_size",      null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "document_queues", ["name"], name: "index_document_queues_on_name", using: :btree

  create_table "document_schemas", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",       null: false
    t.json     "data",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "document_schemas", ["name"], name: "index_document_schemas_on_name", using: :btree

  create_table "documents", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.json     "properties"
    t.uuid     "session_reader_id", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "extensions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",       null: false
    t.text     "source",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "extensions", ["name"], name: "index_extensions_on_name", using: :btree

  create_table "mappings", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",       null: false
    t.json     "terms",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "mappings", ["name"], name: "index_mappings_on_name", using: :btree

  create_table "rate_limits", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",          null: false
    t.time     "peak_start",    null: false
    t.integer  "peak_duration", null: false
    t.float    "peak_rate",     null: false
    t.float    "off_peak_rate", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "rate_limits", ["name"], name: "index_rate_limits_on_name", using: :btree

  create_table "scripts", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",       null: false
    t.text     "source",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "scripts", ["name"], name: "index_scripts_on_name", using: :btree

  create_table "session_queues", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",          null: false
    t.uuid     "rate_limit_id", null: false
    t.integer  "max_size",      null: false
    t.integer  "concurrency",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "session_queues", ["name"], name: "index_session_queues_on_name", using: :btree

  create_table "session_readers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "session_queue_id",    null: false
    t.uuid     "session_id",          null: false
    t.uuid     "document_adapter_id", null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "sessions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "session_queue_id"
    t.string   "page_format",      null: false
    t.json     "urls",             null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

end
