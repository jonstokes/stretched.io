class CreateExtensions < ActiveRecord::Migration
  def change
    create_table :extensions, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name,   null: false
      t.text   :source, null: false
      t.timestamps      null: false
    end
  end
end
