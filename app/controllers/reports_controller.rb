class ReportsController < ApplicationController
    before_action :require_helpdesk!
    
    def index
      @password_resets = PasswordReset.all
      
      if params[:start_date].present?
        start_date = Date.parse(params[:start_date]) rescue nil
        @password_resets = @password_resets.where("created_at >= ?", start_date.beginning_of_day) if start_date
      end
      
      if params[:end_date].present?
        end_date = Date.parse(params[:end_date]) rescue nil
        @password_resets = @password_resets.where("created_at <= ?", end_date.end_of_day) if end_date
      end
      
      if params[:status].present?
        @password_resets = @password_resets.where(status: params[:status])
      end
      
      case params[:filter]
      when 'today'
        @password_resets = @password_resets.where(created_at: Date.today.all_day)
      when 'this_week'
        @password_resets = @password_resets.where(created_at: Date.today.beginning_of_week..Date.today.end_of_week)
      when 'this_month'
        @password_resets = @password_resets.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month)
      when 'active_only'
        @password_resets = @password_resets.where(status: 'active')
      end
      
      @password_resets = @password_resets.includes(:user, :created_by).order(created_at: :desc)
      
      respond_to do |format|
        format.html
        format.csv do 
          send_data generate_csv(@password_resets), 
            filename: "password_resets_report_#{Date.today}.csv", 
            type: 'text/csv; charset=utf-8; header=present'
        end
        format.pdf do
          pdf = generate_pdf(@password_resets)
          send_data pdf, 
            filename: "password_resets_report_#{Date.today}.pdf", 
            type: 'application/pdf'
        end
        format.xlsx do
          xlsx = generate_xlsx(@password_resets)
          send_data xlsx, 
            filename: "password_resets_report_#{Date.today}.xlsx", 
            type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        end
      end
    end
    
    private
    
    def generate_csv(resets)
      require 'csv'
      
      CSV.generate(headers: true) do |csv|
        csv << ["Transaction ID", "User", "Username", "Created By", "Created At", "Expires At", "Status"]
        
        resets.each do |reset|
          csv << [
            reset.id,
            reset.user.full_name,
            reset.user.username,
            reset.created_by&.full_name || "System",
            reset.created_at,
            reset.expires_at,
            reset.status
          ]
        end
      end
    end

    def generate_pdf(resets)
      require 'prawn'
      
      Prawn::Document.new do
        text "Password Resets Report", size: 20, align: :center
        move_down 20
        
        table([
          ["Transaction ID", "User", "Username", "Created By", "Created At", "Expires At", "Status"]
        ] + resets.map do |reset|
          [
            reset.id.to_s,
            reset.user.full_name,
            reset.user.username,
            reset.created_by&.full_name || "System",
            reset.created_at.to_s,
            reset.expires_at.to_s,
            reset.status
          ]
        end, 
        header: true, 
        width: bounds.width)
      end.render
    end

    def generate_xlsx(resets)
      require 'axlsx'
      
      package = Axlsx::Package.new
      workbook = package.workbook
      
      workbook.add_worksheet(name: "Password Resets") do |sheet|
        # Headers
        sheet.add_row([
          "Transaction ID", 
          "User", 
          "Username", 
          "Created By", 
          "Created At", 
          "Expires At", 
          "Status"
        ])
        
        # Data rows
        resets.each do |reset|
          sheet.add_row([
            reset.id,
            reset.user.full_name,
            reset.user.username,
            reset.created_by&.full_name || "System",
            reset.created_at,
            reset.expires_at,
            reset.status
          ])
        end
      end
      
      package.to_stream.read
    end
end