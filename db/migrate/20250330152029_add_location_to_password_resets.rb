class AddLocationToPasswordResets < ActiveRecord::Migration[7.2]
  def change
    add_reference :password_resets, :location, null: true, foreign_key: true
  end
end
