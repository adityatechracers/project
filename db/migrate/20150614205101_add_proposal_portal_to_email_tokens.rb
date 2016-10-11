class AddProposalPortalToEmailTokens < ActiveRecord::Migration
  def self.up
    ['proposal-accepted','proposal-issued','proposal-issued-2-day-reminder','proposal-issued-1-week-reminder',
      'proposal-issued-1-month-reminder','proposal-issued-2-month-reminder','proposal-issued-3-month-reminder',
      'proposal-contract-signed-notification','proposal-contract-signed-confirmation',
      'proposal-change-order-notification'].each do |v|
      temp = EmailTemplateTokenSet.where(:template_name => v).first
      if !temp.nil?
        temp.available_tokens << 'proposal_portal_url'
        temp.save
      end
    end
  end

  def self.down
    ['proposal-accepted','proposal-issued','proposal-issued-2-day-reminder','proposal-issued-1-week-reminder',
      'proposal-issued-1-month-reminder','proposal-issued-2-month-reminder','proposal-issued-3-month-reminder',
      'proposal-contract-signed-notification','proposal-contract-signed-confirmation',
      'proposal-change-order-notification'].each do |v|
      temp = EmailTemplateTokenSet.where(:template_name => v).first
      if !temp.nil?
        temp.available_tokens.delete('proposal_portal_url')
        temp.save
      end
    end
  end
end
