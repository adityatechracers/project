if Rails.env.production?
  Corkcrm::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => "[corkCRM] ",
    :sender_address => %{"notifier" <notifier@corkcrm.com>},
    :exception_recipients => %w{rodoard@gmail.com tsalpekar21@gmail.com mellensadnetoc@jay.washjeff.edu michael@corkcrm.com hassanzahid114295@gmail.com}
elsif Rails.env.staging?  
  Corkcrm::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => "[corkCRM] ",
    :sender_address => %{"notifier" <notifier@corkcrm.com>},
    :exception_recipients => %w{tsalpekar21@gmail.com mellensadnetoc@jay.washjeff.edu michael@corkcrm.com hassanzahid114295@gmail.com}
else Rails.env.development?  
 Corkcrm::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => "[corkCRM] ",
    :sender_address => %{"notifier" <notifier@corkcrm.com>},
    :exception_recipients => %w{rodoard@gmail.com hassanzahid114295@gmail.com}

end
