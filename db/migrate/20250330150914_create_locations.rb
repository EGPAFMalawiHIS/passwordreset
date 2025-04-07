class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations do |t|
      t.string :name
      t.text :description
      t.boolean :retired
      t.string :uuid

      t.timestamps
    end
  end
end
