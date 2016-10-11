include ActionView::Helpers::TextHelper

class LeadsController < ApplicationController
  before_filter :authenticate_user!, :except => [:embed_schedule, :embed_ask_questions]
  load_and_authorize_resource :class => Job, :except => [:new, :embed_schedule, :embed_ask_questions]
  layout :pick_layout

  def new
    authorize! :manage, Job
    @contact = Contact.new
    @job = @contact.jobs.build
    @communication = @job.communications.build
  end

  def index
    page = params.has_key?(:page) ? params[:page] : 1
    filter = params.has_key?(:filter) ? params[:filter] : "active"
    @communication = Communication.new

    @leads = @leads.where(:lead_source_id => params[:lead_source]) if params.has_key? :lead_source
    @leads = @leads.leads_from_time_range(@date_range_filter_start, @date_range_filter_end) if date_range_filter_set?
    @leads = (filter == "dead") ? @leads.dead_leads : @leads.active_leads
    @leads = @leads
      .includes(:next_communication)
      .order("(CASE WHEN communications.datetime IS NULL THEN 1 ELSE 0 END) DESC, communications.datetime ASC, jobs.updated_at DESC")
      .includes([
                    {:last_communication => :user},
                    {:communication_records => :user},
                    :next_appointment,
                    :contact,
                    :lead_source
                ])
      .page(page)
      .per(20)
  end

  def import
    if request.post?
      if params[:leads_file].present?
        if params[:leads_file][:csv].present? && File.extname(params[:leads_file][:csv].original_filename) == ".csv"
          lu = LeadUpload.new(params[:leads_file])
          if lu.save
            render :partial => "import_form", :locals => {:columns => lu.header_options, :lead_upload => lu.id}
          else
            render :text => "<div class='alert alert-block alert-error'>There was a problem saving your CSV upload!</div>"
          end
        else
          render :text => "<div class='alert alert-block alert-error'>The file you uploaded was not in CSV format!</div>"
        end
      else
        lu = LeadUpload.find(params[:lead_upload])
        result = lu.process(params[:leads_import][:contact])
        if result.is_a? String
          render :text => result
        else
          render :text => (pluralize(result, "lead") + " imported successfully.").gsub("job","lead").gsub("Job","Lead")
        end
      end
    end
  end

  def show
  end

  def table
    page = params.has_key?(:page) ? params[:page] : 1
    filter = params.has_key?(:filter) ? params[:filter] : "active"
    @communication = Communication.new
    unless params[:query].blank?
      fields = [:first_name, :last_name, :address, :address2, :city, :region, :country, :zip, :phone, :email ]
      search_params = Hash[fields.map { |f| [f, params[:query]] }]
      @contacts = Contact.basic_search(search_params, false)
      @leads = @leads.where('contact_id in (?)', @contacts)
    end
    @leads = @leads.where(:lead_source_id => params[:lead_source]) if params.has_key? :lead_source
    @leads = @leads.leads_from_time_range(@date_range_filter_start, @date_range_filter_end) if date_range_filter_set?
    @leads = (filter == "dead") ? @leads.dead_leads : @leads.active_leads
    @leads = @leads
      .includes(:next_communication)
      .order("(CASE WHEN communications.datetime IS NULL THEN 1 ELSE 0 END) DESC, communications.datetime ASC, jobs.updated_at DESC")
      .includes([
                    {:last_communication => :user},
                    {:communication_records => :user},
                    :next_appointment,
                    :contact,
                    :lead_source
                ])
      .page(page)
      .per(20)
    render :partial => "table"
  end

  def destroy
    @job = Job.find(params[:id])
    authorize! :manage, @job
    redirect_to leads_path, :notice => "The lead has been successfully deleted." if @job.destroy
  end

  def export
    send_data generate_csv, :filename => "exported_leads.csv", :type => "text/csv"
  end

  def print
    @leads = Job.leads.all
  end

  def embed_schedule
    return redirect_to embed_ask_questions_leads_path(params.except(:action)) if params[:appointment_form] == '0'
    params[:org] ||= current_tenant && current_tenant.guid
    @org = Organization.find_by_guid!(params[:org])
    @contact = Contact.new
    sources = LeadSource.where("name = ? AND organization_id != 0", "Web Form")
    @source = if sources.any?
                sources.first
              else
                LeadSource.create :name => 'Web Form', :organization_id => @org.id
              end
    @job = @contact.jobs.build(:state => "Lead", :lead_source_id => @source.id)
    @appointment = @job.appointments.build
  end

  def embed_ask_questions
    raise 'Select at least one option to embed' if params[:lead_form] == '0'
    params[:org] ||= current_tenant && current_tenant.guid
    @org = Organization.find_by_guid!(params[:org])
    @contact = Contact.new
    sources = LeadSource.where("name = ? AND organization_id != 0", "Web Form")
    @source = if sources.any?
                sources.first
              else
                LeadSource.create :name => 'Web Form', :organization_id => @org.id
              end
    @job = @contact.jobs.build(:state => "Lead", :lead_source_id => @source.id)
    @communication = @job.communications.build(:datetime_exact => true, :type => "Call")
  end

  private

  def generate_csv
    CSV.generate({}) do |csv|
      csv << Contact.columns.map {|c| "Contact "+c.name} + Job.columns.map {|c| "Job "+c.name}
      Job.leads.each {|job| csv << job.contact.attributes.values_at(*job.contact.attribute_names) + job.attributes.values_at(*job.attribute_names)}
    end
  end

  def pick_layout
    return "embed" if [embed_leads_path, embed_ask_questions_leads_path].include? request.fullpath.split("?")[0]
    return "print" if request.fullpath =~ /print/
    "dashboard"
  end
end
