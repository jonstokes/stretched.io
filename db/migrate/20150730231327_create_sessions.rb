class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.uuid   :session_queue_id
      t.string :page_format,       null: false
      t.json   :urls,              null: false
      t.timestamps                 null: false
    end
  end
end
