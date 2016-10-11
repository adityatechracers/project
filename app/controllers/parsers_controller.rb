class ParsersController < ApplicationController
  
    #create contact, job, communication from email parse data.
    def fetch_parse_data
      contact_params = params[:parser]
      organization_id = contact_params[:organization_info].present? ? contact_params[:organization_info].split(".")[1].split('@')[0].strip : nil
      organization = Organization.find(organization_id) if organization_id
      email_body = contact_params[:email_body]
    
      #Parse record if organization is_parse true.
      if organization && organization.is_parse && [contact_params[:email], contact_params[:first_name]].any?(&:present?)
        full_name = contact_params[:full_name].split(" ")
        fname = full_name[0]
        lname = full_name[1].present? ?  full_name[1] : full_name[0]
        contact = Contact.where(first_name: fname, last_name: lname, phone: contact_params[:phone], email: contact_params[:email], organization_id: organization.id)
        new_contact = Contact.new(first_name: fname, last_name: lname, phone: contact_params[:phone], email: contact_params[:email], address: contact_params[:address], city: contact_params[:city], region: contact_params[:state], zip: contact_params[:zip], organization_id: organization.id) unless contact.present?
        begin
          if new_contact && new_contact.save(:validate=> false)
            user = organization.owner
            j = {:contact_id => new_contact.id, :organization_id => organization.id, :title => "Untitled Job", :added_by => user.id }
            job = Job.create!(j)
            OrganizationsMailer.email_parse_success(organization,  email_body).deliver if organization
          else
            OrganizationsMailer.email_parse_error(organization,  email_body).deliver if organization 
          end           
        rescue Exception => ex
          puts "An error of type #{ex.class} happened, message is #{ex.message}"
        end
      else
        OrganizationsMailer.email_parse_error(organization,  email_body).deliver if organization
      end    
      render :nothing => true, :status => 200, :content_type => 'text/html'
    end
end