class PagesController < HighVoltage::PagesController
  before_filter :layout_for_page

  def layout_for_page
    return self.class.layout 'embed' if params[:id] =~ /embed/
    return self.class.layout 'print' if params[:id] =~ /print/
    return self.class.layout 'dashboard' if params[:id] =~ /(dashboard|subscription|communications|jobs|reports|lead|contacts|appointments|proposals|owner|admin)/
    return self.class.layout 'dashboard' if request.path == '/pages/home/termsofservice'
    self.class.layout 'application'
  end
end
