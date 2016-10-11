class Utils::Excel 
  attr_reader :package
  def initialize 
    @package = Axlsx::Package.new
    @workbook = package.workbook
  end   
  def generate(&commands)
    self.instance_eval &commands
    self
  end 
  def sheet name 
    @sheet = @workbook.add_worksheet(name: name)
  end   
  def column data
    add_row(data.respond_to?(:values) ? data.values: data)
  end 
  def rows data
    data.each do |row|
        add_row(row.values)
    end
  end  
  def stream
    package.to_stream
  end     
  def serialize options 
    package.serialize options
  end   
  private 
  def add_row row
    @sheet.try(:add_row, row)
  end  
end   