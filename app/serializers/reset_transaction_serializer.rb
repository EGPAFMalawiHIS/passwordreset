class ResetTransactionSerializer < ActiveModel::Serializer
  attributes :id, :reset_code, :formatted_reset_code, :status, :created_at, :expires_at, :location, :date_of_birth, :sex

  belongs_to :user

  def formatted_reset_code
    object.formatted_reset_code
  end
end

