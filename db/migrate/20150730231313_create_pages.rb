class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.uuid    :session_id,    null: false
      t.string  :url,           null: false
      t.integer :code,          null: false
      t.integer :response_time, null: false
      t.json    :headers,       null: false
      t.timestamps              null: false
    end
  end
end
