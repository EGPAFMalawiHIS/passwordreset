class CreateResetTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :reset_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :reset_code, null: false
      t.integer :status, default: 0
      t.datetime :expires_at
      t.string :location
      t.date :date_of_birth
      t.string :sex

      t.timestamps
    end
    add_index :reset_transactions, :reset_code, unique: true
  end
end

