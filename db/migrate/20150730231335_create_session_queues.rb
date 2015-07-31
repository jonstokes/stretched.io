class CreateSessionQueues < ActiveRecord::Migration
  def change
    create_table :session_queues, id: :uuid, default: "uuid_generate_v4()"  do |t|
      t.string  :name,          null: false
      t.uuid    :rate_limit_id, null: false
      t.integer :max_size,      null: false
      t.timestamps              null: false
    end
  end
end
