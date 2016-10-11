class ProposalsController < ApplicationController
  CUSTOMER_ACTIONS = [
    :proposal_portal,
    :contract_portal,
    :show,
    :print,
    :print_contract,
    :store_signatures,
    :contract
  ]

  before_filter :authenticate_user!, :except => CUSTOMER_ACTIONS
  before_filter :find_proposal_and_set_tenant, :only => CUSTOMER_ACTIONS
  before_filter :set_media_flags
  before_filter :set_default_pdf_options
  load_and_authorize_resource :except => CUSTOMER_ACTIONS, :find_by => :guid
  layout Proc.new {|controller| controller.request.fullpath =~ (/(print|portal)/) ? "print" : "dashboard"}

  def new
    params[:ptid] ||= ProposalTemplate.first().id unless params.has_key?(:proposal) && params[:proposal].has_key?(:proposal_template_id)
    @proposal.job_id = params[:job_id] if params.has_key? :job_id
    @proposal.license_number ||= current_tenant.license_number
    @template = ProposalTemplate.find(params[:ptid] || params[:proposal][:proposal_template_id])
    @sections = @proposal.section_responses.build
    @items = @sections.item_responses.build
    @active_leads = Job.active_leads.accessible_by(current_ability).includes(:contact)
    @active_users = current_user.organization.users.where(:active => true)
    @contact_rating = ContactRating.new
    set_proposal_number
  end

  def create
    @proposal.sales_person ||= current_user
    @proposal.contractor ||= current_user
    @proposal.added_by = current_user.id
    @template = @proposal.template
    upload_your_own = @template.is_upload_your_own?

    if upload_your_own && params[:primary_proposal_file].nil?
      flash[:error] = "There was no primary proposal file attached, try again."
      render :new and return
    end

    if @proposal.save

      if current_tenant.show_customer_rating && params[:contact_rating]
        if params[:contact_rating][:rating_id].present? && params[:contact_rating][:contact_id].present?
          @contact_rating = ContactRating.where(:contact_id => params[:contact_rating][:contact_id], :stage => 'Proposal').first
          if !@contact_rating.blank?
            ContactRating.update(@contact_rating[:id],:rating_id => params[:contact_rating][:rating_id])
          else
            @contact_rating = ContactRating.new(params[:contact_rating])
            @contact_rating.save
          end
        end
      end
      successfully_added_files = @proposal.add_files(params[:primary_proposal_file],
                                                     params[:secondary_proposal_files]) if upload_your_own
      if upload_your_own && !successfully_added_files
        redirect_to proposal_path(@proposal.guid), :flash => {:error => "Failed to upload attachment(s)"} and return
      end
      redirect_to proposal_path(@proposal.guid), :flash => {:success => "Your proposal has been created successfully"}
    else
      @contact_rating = ContactRating.new
      @active_leads = Job.active_leads.accessible_by(current_ability)
      render "new", :error => "There was a problem with your proposal, please try again"
    end
  end

  def index
    @templates = ProposalTemplate.active
    @proposals = case params[:filter]
                 when "accepted" then @proposals.accepted
                 when "declined" then @proposals.declined
                 when "issued" then @proposals.issued
                 else @proposals.unaccepted.not_declined
                 end
    @proposals = @proposals.where(:job_id => params[:job]) if params.has_key?(:job)
    @proposals = @proposals.where(sales_person_id: params[:sales_person]) if params.has_key?(:sales_person)
    @proposals = @proposals.includes([{:job => [:contact]}, :contractor, :sales_person, :versions, :creator]).order("updated_at DESC").page(params[:page])

  end

  def table
    @contacts = Contact.not_deleted
    unless params[:query].blank?
      fields = [:first_name, :last_name, :address, :address2, :city, :region, :country, :zip, :phone, :email ]
      search_params = Hash[fields.map { |f| [f, params[:query]] }]
      @contacts = @contacts.basic_search(search_params, false)
    end
    @jobs = Job.where('contact_id in (?)',@contacts).pluck(:id)
    @proposals = Proposal.where('job_id in (?)',@jobs)
    @proposals = case params[:filter]
                 when "accepted" then @proposals.accepted
                 when "declined" then @proposals.declined
                 when "issued" then @proposals.issued
                 else @proposals.unaccepted.not_declined
                 end

    @proposals_by_title = []
    unless params[:query].blank?
      fields_prop = [:title, :proposal_number]
      search_params_prop = Hash[fields_prop.map { |f| [f, params[:query]] }]
      @proposals_by_title = Proposal.not_deleted.basic_search(search_params_prop, false)
      @proposals_by_title = case params[:filter]
                 when "accepted" then @proposals_by_title.accepted
                 when "declined" then @proposals_by_title.declined
                 when "issued" then @proposals_by_title.issued
                 else @proposals_by_title.not_declined
                 end
    end
    @proposals = @proposals + @proposals_by_title
    @proposals = @proposals.uniq
    render :partial => "table"
  end

  def edit
    redirect_to proposals_path, :notice => 'Accepted proposals cannot be edited' if @proposal.accepted?
    @template = ProposalTemplate.find(@proposal.template.id)
    @contact_rating = ContactRating.new
    @active_leads = Job.active_leads.accessible_by(current_ability).includes(:contact)
    @active_leads << @proposal.job
    @job = @proposal.job
    @contact = @job.contact
    @title = @proposal.title
    @active_users = current_user.organization.users.where(:active => true)
  end

  def update
    params[:proposal][:customer_sig_user_id] = current_user.id unless params[:proposal][:customer_sig].blank?
    params[:proposal][:contractor_sig_user_id] = current_user.id unless params[:proposal][:contractor_sig].blank?
    @active_leads = Job.active_leads.accessible_by(current_ability)
    @active_leads << @proposal.job
    @contact = @proposal.job.contact

    if @proposal.update_attributes params[:proposal]
      if current_tenant.show_customer_rating && params[:contact_rating]
        if params[:contact_rating][:rating_id].present? && params[:contact_rating][:contact_id].present?
          @contact_rating = ContactRating.where(:contact_id => params[:contact_rating][:contact_id], :stage => 'Proposal').first
          if !@contact_rating.blank?
            ContactRating.update(@contact_rating[:id],:rating_id => params[:contact_rating][:rating_id])
          else
            @contact_rating = ContactRating.new(params[:contact_rating])
            @contact_rating.save
          end
        end
      end
      if @proposal.declined?
        redirect_to proposals_path, :flash => {:success => "Your proposal has been marked as declined"}
      else
        redirect_to proposal_path(@proposal.guid), :flash => {:success => "Your proposal has been updated successfully"}
      end
    else
      @contact_rating = ContactRating.new
      @template = ProposalTemplate.find(@proposal.template.id)
      render "edit", :error => "There was a problem with your proposal, please try again"
    end
  end

  def destroy
    redirect_to proposals_path, :notice => "The proposal has been successfully deleted" if @proposal.destroy
  end

  def void_contract
    if @proposal.update_attributes({
      :proposal_state => "Active", :customer_sig_printed_name => nil, :customer_sig => nil,
      :customer_sig_user_id => nil, :customer_sig_datetime => nil, :contractor_sig_printed_name => nil,
      :contractor_sig => nil, :contractor_sig_user_id => nil, :contractor_sig_datetime => nil
    })
      redirect_to :back, :flash => {:success => "Your contract has been voided"}
    else
      redirect_to :back, :error => "Something went wrong..."
    end
  end

  def email_proposal
    ProposalsMailer.proposal(@proposal).deliver
    addresses = ProposalsMailer.contacts(@proposal).to_sentence
    redirect_to proposals_path, :notice => "Proposal ##{@proposal.proposal_number} has been sent to #{addresses}"
  end

  def issue
    @proposal.proposal_state = "Issued" if @proposal.proposal_state == "Active"
    @contact = @proposal.job.contact
    @proposal.save

    begin
      ProposalsMailer.proposal(@proposal).deliver
      addresses = ProposalsMailer.contacts(@proposal).to_sentence
      redirect_to proposals_path, :notice => "Proposal ##{@proposal.proposal_number} has been issued. Email sent to #{addresses}"
    rescue
      @proposal.proposal_state = "Active" if @proposal.proposal_state == "Issued"
      @proposal.save
      redirect_to proposals_path, :notice => "Something went wrong. Email couldn't be generated. Please try again"
    end
  end

  # Non-authenticated actions

  def show
    @proposal = Proposal.find_by_guid!(params[:id], include: [{change_orders: [:user, :proposal], section_responses: [:template_section, {item_responses: [:template_item]}]}])
    @change_order = @proposal.change_orders.new
    # Only allow the pdf when not signed in.
    authorize! :read, Proposal unless request.format == 'pdf'
    @show_contract = params.has_key?(:contract)
    @primary_file = @proposal.template.is_upload_your_own? &&
                    @proposal.proposal_files.detect { |f| f.is_primary_proposal_file? }
    @job = @proposal.job
    @contact = @job.contact
    @title = @proposal.title
    respond_to do |format|
      format.html
      format.pdf do
        @is_print = true
        template = case @proposal.organization.proposal_style
                   when Organization::ProposalStyle::SIMPLE then 'show_simple'
                   when Organization::ProposalStyle::CORKCRM then 'show'
                   else raise 'Invalid or unsupported proposal style'
                   end
        render pdf: @proposal.pdf_name, template: "proposals/#{template}", layout: 'pdf.html', handlers: [:haml], formats: [:pdf],
               grayscale: false, no_background: false, page_size: @proposal.organization.proposal_paper_size
      end
    end
  end

  def print
    @is_print = true
    @show_contract = params.has_key?(:contract)
    @proposal = Proposal.find_by_guid!(params[:id])
    @contact = @proposal.job.contact
  end

  def contract
    authenticate_user! unless request.format.pdf?
    @proposal = Proposal.find_by_guid!(params[:id])
    @job = @proposal.job
    @contact = @job.contact
    @title = @proposal.title
    respond_to do |format|
      format.html
      format.pdf do
        @is_print = true
        template = case @proposal.organization.proposal_style
                   when Organization::ProposalStyle::SIMPLE then 'contract_simple'
                   when Organization::ProposalStyle::CORKCRM then 'contract'
                   else raise 'Invalid or unsupported proposal style'
                   end
        render pdf: "#{@proposal.pdf_name}-contract", template: "proposals/#{template}", layout: 'pdf.html',
               page_size: @proposal.organization.proposal_paper_size, handlers: [:haml], formats: [:pdf]
      end
    end
  end

  def print_contract
    @is_print = true
    @contact = @proposal.job.contact
    @proposal = Proposal.find_by_guid! params[:id]
  end

  def contract_portal
    @proposal = Proposal.find_by_guid! params[:id]
    @job = @proposal.job
    @contact = @job.contact
    @title = @proposal.title
  end

  def proposal_portal
    @proposal = Proposal.find_by_guid! params[:id]
    @job = @proposal.job
    @contact = @job.contact
    @title = @proposal.title
  end

  def store_signatures
    @proposal = Proposal.find_by_guid! params[:id]

    customer_signed = params[:proposal][:customer_sig].present?
    contractor_signed = params[:proposal][:contractor_sig].present?

    if current_user.present?
      params[:proposal][:customer_sig_user_id] = current_user.id if customer_signed
      params[:proposal][:contractor_sig_user_id] = current_user.id if contractor_signed
    end

    if @proposal.update_attributes params[:proposal]
      redirect_to contract_portal_path(params[:id]),
        :flash => {:success => "Your signature#{customer_signed && contractor_signed ? 's have' : ' has'} been stored"}
    else
      redirect_to contract_portal_path(params[:id]), :error => "There was a problem storing your signatures, please try again"
    end
  end

  def upload_files
    @proposal = Proposal.find_by_guid! params[:id]

    if request.referer.include?('contacts')
      if params[:attachment_proposal_files].nil? && params[:primary_proposal_file].nil?  && params[:secondary_proposal_files].nil?
        redirect_to request.referer, :flash => {:error => "Error, didn't select any files to upload"}
        return
      end

      @files = params[:attachment_proposal_files]
      size_array = @files.collect { |e| e.size }
      if size_array.inject(0, :+) > 50.megabytes || @files.count > 10
        redirect_to request.referer, :flash => {:error => "Cannot upload more than 10 files Or more than 50 megabytes at a time"}
        return
      end

      if !@proposal.add_files(params[:primary_proposal_file], params[:secondary_proposal_files], params[:attachment_proposal_files])
        redirect_to request.referer, :flash => {:error => "Failed to upload attachment(s)"} and return unless uploaded
      end
     
      redirect_to request.referer, :flash => {:success => "The file(s) were successfully uploaded"}
    else
      if params[:attachment_proposal_files].nil? && params[:primary_proposal_file].nil?  && params[:secondary_proposal_files].nil?
        redirect_to proposal_path(@proposal.guid), :flash => {:error => "Error, didn't select any files to upload"}
        return
      end

      @files = params[:attachment_proposal_files]
      size_array = @files.collect { |e| e.size }
      if size_array.inject(0, :+) > 50.megabytes || @files.count > 10
        redirect_to proposal_path(@proposal.guid), :flash => {:error => "Cannot upload more than 10 files Or more than 50 megabytes at a time"}
        return
      end

      if !@proposal.add_files(params[:primary_proposal_file], params[:secondary_proposal_files], params[:attachment_proposal_files])
        redirect_to proposal_path(@proposal.guid), :flash => {:error => "Failed to upload attachment(s)"} and return unless uploaded
      end
     
      redirect_to proposal_path(@proposal.guid), :flash => {:success => "The file(s) were successfully uploaded"}
    end    
  end

  def header_table_preview
    @job = Job.find_by_id(params[:proposal][:job_id])
    @proposal = params[:proposal_guid].present? ? Proposal.find_by_guid(params[:proposal_guid]) : Proposal.new(params[:proposal])
    @title = params[:proposal][:title]
    @contact = @job.contact
    @proposal.sales_person = params[:proposal][:sales_person_id].present? ? User.find(params[:proposal][:sales_person_id]) : @proposal.sales_person
    @proposal.sales_person ||= current_user
    @proposal.contractor ||= current_user
    @proposal.added_by = current_user.id

    if params[:proposal][:proposal_date].present?
      @proposal.proposal_date = params[:proposal][:proposal_date]
    else
      @proposal.proposal_date = Time.now
    end
    
    @proposal.updated_at = Time.now
    render :layout => false
  end

  def form_generated
    @proposal = Proposal.new(params[:proposal])
    @proposal.sales_person ||= current_user
    @proposal.contractor ||= current_user
    @proposal.added_by = current_user.id
    respond_to do |format|
      format.js
    end
    # render :layout => false

  end

  def get_contact_rating
    @rating_id = ContactRating.where(contact_id: params[:contact], stage: params[:stage]).first
    if @rating_id
      render :text => @rating_id.rating_id
    else
      render :text => 1
    end

  end


  private

  def set_media_flags
    @is_print = false
  end

  # This little feature assigns default proposal options from a JSON object
  # stored on the organization. It's used to support custom render options for
  # specific organizations.
  def set_default_pdf_options
    @proposal_options = {}

    if params[:format] == 'pdf' && @proposal.present? && @proposal.organization.proposal_options.present?
      begin
        JSON.parse(@proposal.organization.proposal_options).each do |k, v|
          @proposal_options[k.to_sym] = params.has_key?(k) ? parse_param_val(params[k], v.class) : v
        end
      rescue => e
        logger.error e.message
        logger.error e.backtrace
      end
    end
  end

  def parse_pdf_option(val, klass)
    if klass.in?(TrueClass, FalseClass)
      val.in?('1', 'true', 'on')
    else
      val
    end
  end

  def find_proposal_and_set_tenant
    @proposal = Proposal.find_by_guid(params[:id])
    if current_tenant.nil? && @proposal.present?
      set_current_tenant(@proposal.organization)
    end
  end

  def set_proposal_number
    @proposal.proposal_number = 10000 + rand(89999)
    while Proposal.find_by_proposal_number(@proposal.proposal_number).present?
      @proposal.proposal_number = 10000 + rand(89999)
    end
  end
end
