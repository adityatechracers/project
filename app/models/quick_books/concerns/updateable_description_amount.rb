module QuickBooks::UpdateableDescriptionAmount
  extend ActiveSupport::Concern 
  module ClassMethods 
    def acts_as_updateable_description_amount options={}
      belongs = options[:belongs_to]
      belongs_to belongs, class_name: "::#{belongs.to_s.classify}"
      belongs_to_sym = "#{belongs}_id".to_sym
      attr_accessible belongs_to_sym, :amount
      validates belongs_to_sym, :amount, presence:true
      before_destroy :destroy_belongs_to
      [options[:description_field] || :description, :amount].each do |attribute|
        define_method("update_#{attribute}") do |update|
          do_update attribute, update
        end   
      end 
      private  
      define_method "get_belongs_to" do 
        self.send options[:belongs_to]
      end   
    end 
  end
  private    
  def destroy_belongs_to 
    get_belongs_to.destroy
  end  
  def do_update column, value 
    update_column column, value
    p "#{get_belongs_to.inspect}"
    get_belongs_to.send "qb_update_#{column.to_s}", value
  end     
end
