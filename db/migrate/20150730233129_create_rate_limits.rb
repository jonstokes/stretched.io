class CreateRateLimits < ActiveRecord::Migration
  def change
    create_table :rate_limits, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string  :name,          null: false
      t.time    :peak_start,    null: false
      t.integer :peak_duration, null: false
      t.float   :peak_rate,     null: false, precision: 5, scale: 2
      t.float   :off_peak_rate, null: false, precision: 5, scale: 2
      t.timestamps              null: false
    end
  end
end
