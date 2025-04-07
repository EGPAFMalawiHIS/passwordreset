class AddResetCodeToPasswordResets < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:password_resets, :reset_code)
      add_column :password_resets, :reset_code, :string
    end
  end
end

