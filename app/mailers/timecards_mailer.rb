class TimecardsMailer < BaseMailer
  layout 'corkcrm_mailer'

  def change_notification(old, new)
    @old_timecard = old
    @new_timecard = new
    mail(:to => old.user.email, :subject => 'CorkCRM: Your timecard has changed')
  end
end
