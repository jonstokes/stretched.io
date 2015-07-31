class CreateDocumentAdapters < ActiveRecord::Migration
  def change
    create_table :document_adapters, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name,               null: false
      t.uuid   :document_schema_id, null: false
      t.uuid   :document_queue_id,  null: false
      t.uuid   :template_id
      t.string :xpath
      t.json   :property_queries,   null: false
      t.text   :scripts,            array: true

      t.timestamps                  null: false
    end
  end
end
