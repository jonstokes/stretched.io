class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.uuid   :session_queue_id,  null: false
      t.string :page_format,       null: false
      t.text   :document_adapters, null: false, array: true
      t.text   :urls,              null: false, array: true
      t.timestamps                 null: false
    end
  end
end
