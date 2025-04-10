class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :username, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: 'user'
      
      t.timestamps
    end
    
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
  end
end