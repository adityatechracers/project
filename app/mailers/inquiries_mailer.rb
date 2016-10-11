class InquiriesMailer < BaseMailer
  layout 'corkcrm_mailer'

  def new_inquiry(inquiry)
    @inquiry = inquiry
    mail(:subject => 'CorkCRM: New Inquiry', :to => self.class.admin_email_addresses)
  end
end
