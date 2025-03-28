class BarcodeService
  def self.generate_barcode(code)
    require 'barby'
    require 'barby/barcode/code_128'
    require 'barby/outputter/png_outputter'
    
    # Create the barcode
    barcode = Barby::Code128.new(code)
    
    # Generate PNG as base64
    base64_output = Base64.strict_encode64(barcode.to_png(height: 50, margin: 5))
    
    # Return data URI for embedding in PDF or HTML
    "data:image/png;base64,#{base64_output}"
  end
end

