class CreateMappings < ActiveRecord::Migration
  def change
    create_table :mappings, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name,  null: false
      t.json   :terms, null: false
      t.timestamps     null: false
    end
  end
end
