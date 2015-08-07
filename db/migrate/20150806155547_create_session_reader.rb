class CreateSessionReader < ActiveRecord::Migration
  def change
    create_table :session_readers, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.uuid :session_queue_id,    null: false
      t.uuid :session_id,          null: false
      t.uuid :document_adapter_id, null: false
      t.timestamps                 null: false
    end
  end
end
