class AddNestOnToReading < ActiveRecord::Migration
  def change
    add_column :readings, :nest_on, :boolean
  end
end
