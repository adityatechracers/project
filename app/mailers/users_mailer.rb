class UsersMailer < BaseMailer
  default from: "accounts@corkcrm.com"

  def welcome(user)
    tokens = {
      'user_first_name' => user.first_name,
      'user_last_name' => user.last_name,
      'organization_name' => user.organization_name
    }
    system_mail_templated('welcome', tokens, to: user.email, lang: user.organization.language)
  end

  def new_organization_user(user, generated_password)
    self.class.layout 'corkcrm_mailer'
    @user = user
    @generated_password = generated_password
    mail(to: user.email, subject: 'Welcome to CorkCRM')
  end

  def notify_admin(user)
    @user = user
    mail(to: 'michaelhenry91@gmail.com', subject: 'CorkCRM: a new user has joined!')
  end

end
