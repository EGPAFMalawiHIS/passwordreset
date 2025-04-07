class IncreaseResetCodeColumnSize < ActiveRecord::Migration[7.2]
  def change
    remove_index :password_resets, :reset_code if index_exists?(:password_resets, :reset_code)
    change_column :password_resets, :reset_code, :string, limit: 1024
  end
end
