module Exportable 
  extend ActiveSupport::Concern

  def export_data 
    cookies.delete :exportFinished 
    result = yield
    cookies[:exportFinished] = 'true'
    result
  end   

end   