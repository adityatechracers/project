require 'spec_helper'

module CheckPageHelpers
  def on_page?(pagetitle)
    find('.subnav_list.active').should have_content pagetitle
  end

  def current_page
    find('.subnav_list.active')
  end
end
