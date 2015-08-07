class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.json :properties
      t.uuid :session_reader_id, null: false

      t.timestamps                 null: false
    end
  end
end
