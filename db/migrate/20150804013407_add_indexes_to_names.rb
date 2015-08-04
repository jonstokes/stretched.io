class AddIndexesToNames < ActiveRecord::Migration
  def change
    add_index :document_schemas,  :name, using: :btree
    add_index :document_adapters, :name, using: :btree
    add_index :document_queues,   :name, using: :btree
    add_index :session_queues,    :name, using: :btree
    add_index :rate_limits,       :name, using: :btree
    add_index :mappings,          :name, using: :btree
    add_index :scripts,           :name, using: :btree
    add_index :extensions,        :name, using: :btree
  end
end
