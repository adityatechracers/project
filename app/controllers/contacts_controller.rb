class ContactsController < ApplicationController
  before_filter :authenticate_user!, :except => [:create_from_embedded_form]
  load_and_authorize_resource
  skip_load_and_authorize_resource :only => [:create, :create_from_embedded_form]
  helper :proposals

  include Exportable

  def new
  end

  def new_lead
    authorize! :manage, Job
    @contact = Contact.new
    @job = @contact.jobs.build
    @communication = @job.communications.build
  end

  def create
    existing_contact = params[:contact].has_key?(:which) and params[:contact][:which].present?
    @job_nested = params[:contact].has_key?(:jobs_attributes) and params[:contact][:jobs_attributes].present?
    if @job_nested
      job_params = params[:contact][:jobs_attributes]
      params[:contact].delete(:jobs_attributes)
    end

    @contact = existing_contact ? Contact.find(params[:contact][:which]) : Contact.new(params[:contact])
    @show_time_zone_select = false
    error_message = "There was a problem adding your #{@job_nested ? "lead" : "contact"}"
    time_zone_error_message = ""
    @contact.save unless existing_contact
    unless @contact.errors.any?
     check_geocode_reliable unless @job_nested.present?
    end
    if @contact.errors.any?
      flash[:alert] = error_message
      render @job_nested ? 'new_lead' : 'new'
      return
    elsif !@job_nested
      redirect_to contact_path(@contact), :notice => "Your contact was added successfully"
      return
    end

    job_params.each do |i,j|
      j = {:contact_id => @contact.id, :organization_id => @contact.organization_id, :title => "Untitled Job", :added_by => current_user.id}.merge(j)
      job = Job.create!(j)
      if job.present? && job.details.present?
        job.communications.create(:user_id => current_user.id, :action => 'Call', :type => 'CommunicationRecord', :details => job.details, :datetime => DateTime.now, :datetime_exact => true)
      end
    end

    redirect_to leads_path, :notice => "Your lead was added successfully"
  end

  def create_from_embedded_form
    params[:contact][:jobs_attributes]["0"][:state] = "Lead"
    @contact = Contact.new params[:contact]

    if verify_recaptcha(:model => @contact, :message => "There was a problem with your reCaptcha!") and @contact.save
      ActsAsTenant.with_tenant(@contact.jobs.first.organization) do
        JobsMailer.lead_added_via_embed(@contact.jobs.first).deliver
      end
      if params.has_key? :appointment_id
        a = Appointment.find(params[:appointment_id])
        if a.update_attributes(:job_id => @contact.jobs.first.id)
          res = {'data' => 'Appointment saved successfully'}.to_json  
          render :json => res, :status => :created
        else
          res = {'error' => a.errors.full_messages.to_sentence}.to_json
          render :json => res , :status => :unprocessable_entity
        end
      elsif params[:contact][:jobs_attributes]["0"].has_key? :communications_attributes
        res = {'data' => 'Contact saved successfully'}.to_json  
        render :json => res, :status => :created
      end
    else
      res = {'error' => @contact.errors.full_messages.to_sentence}.to_json
      render :json => res , :status => :unprocessable_entity
    end
  end

  def index
    page = params.has_key?(:page) ? params[:page] : 1
    @contacts = @contacts.not_deleted.page(page).per(20)
  end

  def show
    #Notes functionality in contacts removed
    #@job = Job.find_by_contact_id(@contact.id)
    #@communication = @job.communications.new(:user_id => current_user.id)
    @jobs = @contact.jobs.not_deleted
    @appointments = @contact.appointments.not_deleted.includes(:job, :user)
  end

  def edit
    @show_time_zone_select = true if @contact.time_zone.present?
  end

  def update
    if params.has_key?(:redirect_to)
      if @contact.update_attributes params[:contact]
        check_geocode_reliable unless @contact.lead?
      end
      unless @contact.errors.any?
        redirect_to leads_path, :notice => "Your contact was updated successfully"
      else
        render "edit", :error => "There was a problem editing your contact"
      end
    else
      if @contact.update_attributes params[:contact]
        check_geocode_reliable unless @contact.lead?
      end
      unless @contact.errors.any?
        redirect_to contact_path(@contact), :notice => "Your contact was updated successfully"
      else
        render "edit", :error => "There was a problem editing your contact"
      end
    end
  end

  def destroy
    redirect_to contacts_path, :notice => "Your contact was deleted successfully" if @contact.destroy
  end

  def table
    @contacts = @contacts.not_deleted
    unless params[:query].blank?
      fields = [:first_name, :last_name, :address, :address2, :city, :region, :country, :zip, :phone, :email ]
      search_params = Hash[fields.map { |f| [f, params[:query]] }]
      last_name, first_name = params[:query].split(',')
      search_params[:first_name], search_params[:last_name] = first_name, last_name if !first_name.nil? and !last_name.nil?
      @contacts = @contacts.basic_search(search_params, false)
      @contacts = @contacts.basic_search(first_name: first_name).basic_search(last_name: last_name) if !first_name.nil? and !last_name.nil?
    end

    @contacts_by_proposal_number = []
    unless params[:query].blank?
      @proposals_by_number = []
      fields_prop = [:proposal_number]
      search_params_prop = Hash[fields_prop.map { |f| [f, params[:query]] }]
      @proposals_by_number = Proposal.not_deleted.basic_search(search_params_prop, false)
      @contacts_by_proposal_number = Contact.not_deleted.includes(:jobs, :proposals).where('proposals.job_id = jobs.id').where('proposals.id in (?)', @proposals_by_number)
    end

    @contacts = @contacts + @contacts_by_proposal_number
    @contacts = @contacts.uniq

    render :partial => "table"
  end

  def export
    send_data generate_excel.to_stream.read, filename: 'export.xlsx', type: "application/xlsx"
  end

  def generate_excel
    export_data do
      package = Axlsx::Package.new
      workbook = package.workbook

      workbook.add_worksheet(name: 'Contacts') do |sheet|
        contact_columns = Contact.CONTACT_FIELDS_EXPORT.values
        sheet.add_row(contact_columns)
        contacts = Contact.export(current_user.organization_id)

        contacts.each do |contact|
          if current_tenant.show_customer_rating
            @value = Rating.joins(:contact_ratings).where("contact_ratings.contact_id = #{contact['id']} and contact_ratings.stage = 'Appointment'").first
            if @value
              contact['appointment_rating'] = @value.rating
            end
            @value = Rating.joins(:contact_ratings).where("contact_ratings.contact_id = #{contact['id']} and contact_ratings.stage = 'Proposal'").first
            if @value
              contact['proposal_rating']= @value.rating
            end
            @value = Rating.joins(:contact_ratings).where("contact_ratings.contact_id = #{contact['id']} and contact_ratings.stage = 'Completion'").first
            if @value
              contact['job_rating']=@value.rating
            end
          end
          sheet.add_row(contact.values)
        end
      end

      workbook.add_worksheet(name: 'Leads') do |sheet|
        lead_columns = Job.LEAD_FIELDS_EXPORT.values
        sheet.add_row(lead_columns)
        leads = Job.lead_export(current_user.organization_id)

        leads.each do |lead|
          sheet.add_row(lead.values)
        end
      end

      workbook.add_worksheet(name: 'Proposals') do |sheet|
        prop_columns = Proposal.PROPOSAL_FIELDS_EXPORT.values
        sheet.add_row(prop_columns)
        proposals = Proposal.export(current_user.organization_id)

        proposals.each do |proposal|
          sheet.add_row(proposal.values)
        end
      end

      workbook.add_worksheet(name: 'Jobs') do |sheet|
        job_columns = Job.JOB_FIELDS_EXPORT.values
        sheet.add_row(job_columns)
        jobs = Job.job_export(current_user.organization_id)

        jobs.each do |job|
          sheet.add_row(job.values)
        end
      end
      package
    end
  end

  def edit_lead
    authorize! :manage, Job
    @contact = Contact.where(:id => params[:id]).limit(1).first
    #@job = @contact.jobs.build
    #@communication = @job.communications.build
  end

  def zestimate

    require 'net/http'

    uri = URI.parse("http://www.zillow.com/webservice/GetDeepSearchResults.htm")
    zillow_id = 'X1-ZWz1fd94bmdjbf_3o1g1'
    address = params[:address]
    zip = params[:zip]

    # Shortcut
    response = Net::HTTP.post_form(uri, {"zws-id" => zillow_id, "address" => address,"citystatezip"=>zip})


    xml = response.body
    doc = Nokogiri::XML(xml)
    message = doc.xpath("//message")
    if message.xpath("./code").text == '0'
      uri = URI.parse("http://www.zillow.com/webservice/GetZestimate.htm")
      response = doc.xpath("//response")
      zillow_p_id = response.xpath("./results").xpath('./result')[0].xpath('./zpid').text
      response = Net::HTTP.post_form(uri, {"zws-id" => zillow_id, "zpid" => zillow_p_id})

      xml = response.body
      doc = Nokogiri::XML(xml)
      response = doc.xpath("//zestimate")
      render :json => response.xpath("./amount").text
    else
      render :text => message.xpath("./text").text
    end
  end

  def contact_rating
    if current_tenant.show_customer_rating
      if !params[:contact_rating][:rating_id].empty? && !params[:contact_rating][:contact_id].empty?
        @contact_rating = ContactRating.where(:contact_id => params[:contact_rating][:contact_id], :stage => params[:contact_rating][:stage]).first
        if !@contact_rating.blank?
          ContactRating.update(@contact_rating[:id],:rating_id => params[:contact_rating][:rating_id])
        else
          @contact_rating = ContactRating.new(params[:contact_rating])
          @contact_rating.save
        end
      end
    end
    redirect_to :back
  end

  private
  def check_geocode_reliable
    if @contact.time_zone.nil?
      @show_time_zone_select = true unless @contact.geocode_reliable?
    end
    if @show_time_zone_select
      time_zone_error_message = """We are unable to determine the time zone for this contact,
      we've default it to the organization's time zone, please adjust as necessary."""
      @contact.errors.add :time_zone, time_zone_error_message
    end
  end
end
