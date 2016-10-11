namespace :jobs do
  namespace :notify do 
    task :scheduled_job_entry => :environment do
      JobScheduleEntry.send_notifications
    end
  end 
  namespace :ssl do
    desc "Check SSl certificates renewed successfully"
    task :certificates_renewed => :environment do
      Jobs::Ssl::CertificatesRenewed.perform
    end
  end
end
