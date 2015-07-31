class CreateDocumentSchemas < ActiveRecord::Migration
  def change
    enable_extension "uuid-ossp"

    create_table :document_schemas, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name,  null: false
      t.json   :data,  null: false

      t.timestamps     null: false
    end
  end
end
