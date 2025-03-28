class ReportsController < ApplicationController
  before_action :authenticate_user!
  
  # GET /reports/dashboard
  def dashboard
    # Get data for dashboard
    @stats = {
      total_transactions: ResetTransaction.count,
      total_today: ResetTransaction.where('created_at >= ?', Time.zone.now.beginning_of_day).count,
      active_codes: ResetTransaction.active.count,
      expired_codes: ResetTransaction.expired.count,
      used_codes: ResetTransaction.where(status: :used).count
    }
    
    # Get monthly data for charts
    @monthly_data = monthly_transactions_data
  end

  private

  def monthly_transactions_data
    # Get data for the last 6 months
    start_date = 5.months.ago.beginning_of_month
    end_date = Time.current.end_of_month
    
    # Initialize result hash with all months
    result = {}
    date = start_date
    while date <= end_date
      month_name = date.strftime('%B')
      result[month_name] = { active: 0, expired: 0, used: 0 }
      date = date.next_month
    end
    
    # Query for transactions in the date range, grouped by month and status
    transactions = ResetTransaction
      .where(created_at: start_date..end_date)
      .group("DATE_FORMAT(created_at, '%Y-%m')")
      .group(:status)
      .count
    
    # Format the data for the chart
    transactions.each do |(month_str, status), count|
      month = Date.parse("#{month_str}-01").strftime('%B')
      result[month][status.to_sym] = count if result[month]
    end
    
    # Convert to array format for easier consumption by frontend
    result.map do |month, counts|
      {
        month: month,
        active: counts[:active],
        expired: counts[:expired],
        used: counts[:used]
      }
    end
  end
end

