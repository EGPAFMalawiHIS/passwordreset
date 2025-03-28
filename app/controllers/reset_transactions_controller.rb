class ResetTransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show]
  before_action :set_transactions_for_export, only: [:export_csv, :export_pdf, :export_excel]
  
  def index
    @pagy, @transactions = pagy(ResetTransaction.includes(:user).order(created_at: :desc))
  end
  
  def show
  end
  
  def new
    @transaction = ResetTransaction.new
  end
  
  def create
    # Find user if they exist in the system
    @user = User.find_by(username: params[:reset_transaction][:username])
    
    unless @user
      flash.now[:alert] = "User not found"
      return render :new, status: :unprocessable_entity
    end
    
    # Validate user information matches
    unless user_info_matches?(@user)
      flash.now[:alert] = "User information does not match our records"
      return render :new, status: :unprocessable_entity
    end
    
    # Generate reset code
    reset_code = generate_reset_code(@user)
    
    @transaction = @user.reset_transactions.new(
      reset_code: reset_code,
      status: :active,
      location: params[:reset_transaction][:location],
      date_of_birth: params[:reset_transaction][:date_of_birth],
      sex: params[:reset_transaction][:sex]
    )
    
    if @transaction.save
      redirect_to reset_transaction_path(@transaction), notice: "Reset code generated successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def reports
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil
    @status = params[:status]
    
    @transactions = ResetTransaction.includes(:user).order(created_at: :desc)
    
    # Apply filters if provided
    if @start_date && @end_date
      @transactions = @transactions.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
    end
    
    @transactions = @transactions.where(status: @status) if @status.present?
    
    @pagy, @transactions = pagy(@transactions)
    
    respond_to do |format|
      format.html
      format.csv { send_data generate_csv(@transactions), filename: "reset_transactions_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv" }
      format.pdf do
        pdf = TransactionReportPdf.new(@transactions)
        send_data pdf.render, filename: "reset_transactions_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf", type: 'application/pdf', disposition: 'attachment'
      end
      format.xlsx
    end
  end
  
  def export_csv
    respond_to do |format|
      format.csv do
        send_data generate_csv(@transactions),
          filename: "reset_transactions_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv",
          type: 'text/csv',
          disposition: 'attachment'
      end
    end
  end
  
  def export_pdf
    respond_to do |format|
      format.pdf do
        pdf = TransactionReportPdf.new(@transactions)
        send_data pdf.render,
          filename: "reset_transactions_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf",
          type: 'application/pdf',
          disposition: 'attachment'
      end
    end
  end
  
  def export_excel
    respond_to do |format|
      format.xlsx
    end
  end
  
  private
  
  def set_transaction
    @transaction = ResetTransaction.find(params[:id])
  end
  
  def set_transactions_for_export
    # Apply filters if provided
    @transactions = ResetTransaction.includes(:user).order(created_at: :desc)
    
    # Filter by date range if provided
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]).beginning_of_day
      end_date = Date.parse(params[:end_date]).end_of_day
      @transactions = @transactions.where(created_at: start_date..end_date)
    end
    
    # Filter by status if provided
    @transactions = @transactions.where(status: params[:status]) if params[:status].present?
  end
  
  def user_info_matches?(user)
    user.first_name.downcase == params[:reset_transaction][:first_name].downcase &&
    user.last_name.downcase == params[:reset_transaction][:last_name].downcase
  end
  
  def generate_reset_code(user)

    key = ActiveSupport::KeyGenerator.new("CENTRALISED-EMR").generate_key("salt",32)
    crypt = ActiveSupport::MessageEncryptor.new(key)
    data = {
             firstname: user.first_name,
             lastname: user.last_name,
             username: user.username,
             location: params[:reset_transaction][:location],
             expiration_time: Time.now + 24.hour }

         encrypted_data = crypt.encrypt_and_sign(data.to_json)
         return encrypted_data
  end

  def decrypt_reset_code(encrypted_data)
       key = ActiveSupport::KeyGenerator.new("CENTRALISED-EMR").generate_key("salt",32)
     crypt = ActiveSupport::MessageEncryptor.new(key)
     JSON.parse(crypt.decrypt_and_verify(encrypted_data))
  end
  
  def generate_csv(transactions)
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      # Add headers
      csv << ['Transaction ID', 'Username', 'Full Name', 'Reset Code', 'Status', 'Created At', 'Expires At', 'Location']
      
      # Add data rows
      transactions.each do |transaction|
        csv << [
          transaction.id,
          transaction.user.username,
          transaction.user.full_name,
          transaction.formatted_reset_code,
          transaction.status,
          transaction.created_at.strftime('%Y-%m-%d %H:%M:%S'),
          transaction.expires_at.strftime('%Y-%m-%d %H:%M:%S'),
          transaction.location
        ]
      end
    end
  end
end

