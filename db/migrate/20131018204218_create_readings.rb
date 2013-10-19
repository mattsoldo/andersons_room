class CreateReadings < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.decimal :temp
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
