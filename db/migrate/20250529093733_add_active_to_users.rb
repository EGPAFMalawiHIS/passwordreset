class AddActiveToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :active, :boolean, default: false, null: false
  end
end
