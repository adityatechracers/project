module ContactsHelper
  include TimecardsHelper

  def contact_tab_active(contact, flip = false)
    if contact.errors.present? || params[:contact].nil?
      flip ? '' : 'active'
    else
      flip ? 'active' : ''
    end
  end
end
