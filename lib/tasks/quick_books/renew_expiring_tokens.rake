namespace :qb do
  namespace :renew do 
    desc "Renew Quickbook Expiring Tokens"
    task :expiring_tokens => :environment do
      Jobs::QB::RenewExpiringTokens.perform
    end
  end 
end
