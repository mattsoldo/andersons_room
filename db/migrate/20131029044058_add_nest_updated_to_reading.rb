class AddNestUpdatedToReading < ActiveRecord::Migration
  def change
    add_column :readings, :nest_updated, :boolean
  end
end
