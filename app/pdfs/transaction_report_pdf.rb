class TransactionReportPdf < Prawn::Document
  def initialize(transactions)
    super(page_size: "A4", page_layout: :landscape)
    @transactions = transactions
    generate_content
  end
  
  def generate_content
    # Add title
    text "Password Reset Transactions Report", size: 18, style: :bold, align: :center
    text "Generated on: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}", size: 10, align: :center
    move_down 20
    
    # Add summary
    summary_box
    move_down 20
    
    # Add transactions table
    transactions_table
    
    # Add page numbers
    number_pages "Page <page> of <total>", 
                 { start_count_at: 1, 
                   at: [bounds.right - 150, 0], 
                   align: :right,
                   size: 9 }
  end
  
  def summary_box
    active_count = @transactions.select { |t| t.status == "active" }.count
    expired_count = @transactions.select { |t| t.status == "expired" }.count
    used_count = @transactions.select { |t| t.status == "used" }.count
    
    bounding_box([0, cursor], width: bounds.width, height: 80) do
      stroke_bounds
      move_down 10
      
      text "Summary", size: 14, style: :bold, align: :center
      move_down 10
      
      summary_data = [
        ["Total Transactions:", @transactions.count.to_s],
        ["Active:", active_count.to_s],
        ["Expired:", expired_count.to_s],
        ["Used:", used_count.to_s]
      ]
      
      table(summary_data, width: 300, position: :center, cell_style: { borders: [] }) do
        column(0).style(align: :right, font_style: :bold)
        column(1).style(align: :left, padding_left: 10)
      end
    end
  end
  
  def transactions_table
    # Table headers
    headers = ['ID', 'Username', 'Full Name', 'Reset Code', 'Status', 'Created At', 'Expires At', 'Location']
    
    # Table data
    data = @transactions.map do |transaction|
      [
        transaction.id,
        transaction.user.username,
        transaction.user.full_name,
        transaction.formatted_reset_code,
        transaction.status.capitalize,
        transaction.created_at.strftime('%Y-%m-%d %H:%M'),
        transaction.expires_at.strftime('%Y-%m-%d %H:%M'),
        transaction.location
      ]
    end
    
    # Create the table
    table([headers] + data, header: true, width: bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = 'DDDDDD'
      
      # Style for status column
      column(4).style do |cell|
        if cell.content == 'Active'
          cell.text_color = '008800'
        elsif cell.content == 'Expired'
          cell.text_color = 'CC0000'
        end
      end
      
      # Auto-fit columns
      self.row_colors = ['FFFFFF', 'F9F9F9']
      self.cell_style = { size: 9 }
    end
  end
end

