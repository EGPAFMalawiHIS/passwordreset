class CreatePasswordResets < ActiveRecord::Migration[7.2]
  def change
    create_table :password_resets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.string :reset_code, null: false
      t.string :status, null: false, default: 'active'
      t.datetime :expires_at, null: false
      
      t.timestamps
    end
    
    add_index :password_resets, :reset_code, unique: true
    add_index :password_resets, :status
    add_index :password_resets, :expires_at
  end
end