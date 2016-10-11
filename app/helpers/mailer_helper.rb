# Only include this from a mailer. This is used for rendering the wicked_pdf views.
module MailerHelper
  def protect_against_forgery?
    false
  end
end
