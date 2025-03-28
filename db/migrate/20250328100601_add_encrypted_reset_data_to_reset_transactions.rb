class AddEncryptedResetDataToResetTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :reset_transactions, :encrypted_reset_data, :text
  end
end
