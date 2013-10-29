class AddIndextNestUpdatedToReading < ActiveRecord::Migration
  def change
  	add_index :readings, :nest_updated
  end
end
