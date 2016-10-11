module QuickBooks
  class Invoice < ActiveRecord::Base
    include QuickBooks::BaseRecord 
    STATUS=%w(deleted voided unpaid paid)
    belongs_to_sub_customer 
    attr_accessible :amount 
    validates :amount, presence: true
    validates :amount, numericality: { greater_than: 0}
    validates :status, inclusion: {in: STATUS}
    STATUS.each do |status|
      define_method("#{status}!") do 
        unless self.send "#{status}?"
          self.update_column :status, status  
        end   
      end  
      define_method("#{status}") do 
        self.status = status 
      end 
      define_method("#{status}?") do 
        self.status == status 
      end  
    end  
    after_initialize do
      self.unpaid unless status.present?
    end 
  end

end 