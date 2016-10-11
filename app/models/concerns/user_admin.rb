module UserAdmin
  extend ActiveSupport::Concern

  module ClassMethods 
    def admin_export 
      users = User
      .joins("left outer join organizations on users.organization_id = organizations.id")
      .select( 
        """organizations.name as organiation_name, 
           organizations.stripe_plan_id as organization_plan, 
           to_char(users.created_at, 'MM/DD/YY') as date_account_created, 
           concat(users.first_name, users.last_name) as user_name, 
           users.email as user_email, users.role as user_role"""
      )
      OpenStruct.new(
        columns: users.first.attributes.keys.map(&:titleize),
        rows: users.map(&:attributes)
      )
    end   
  end 
end   