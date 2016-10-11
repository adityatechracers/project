class Contact < ActiveRecord::Base
  attr_accessible :address, :time_zone, :address2, :city, :country, :email, :first_name, :last_name, :phone, :region, :zip, :jobs_attributes, :communications_attributes, :organization_id, :company, :zestimate, :discard_zestimate
  attr_accessor :which

  def self.CONTACT_FIELDS_EXPORT
    {'id' => 'id',
     'first_name' => 'First Name',
     'last_name' => 'Last Name',
     'phone' => 'Phone',
     'email' => 'Email',
     'address' => 'Address',
     'address2' => 'Address 2',
     'city' => 'City',
     'region' => 'State',
     'zip' => 'Zip',
     'zestimate' => 'Zestimate (USD)',
     'company' => 'Company',
     'appointment_rating' => 'Rating at appointment stage',
     'proposal_rating' => 'Rating at proposal stage',
     'job_rating' => 'Rating at job stage',
     'deleted' => 'Deleted At'}
  end

  def self.export(organization_id)

    sql = <<-SQL
      SELECT id,TRIM(first_name) AS first_name, TRIM(last_name) AS last_name, phone, email,
      address, address2, city, region, zip, zestimate, company,'' as appointment_rating ,'' as proposal_rating,'' as job_rating,
      CASE WHEN deleted_at IS NOT NULL THEN deleted_at ELSE NULL END AS deleted
      FROM contacts
      WHERE organization_id = #{organization_id}
      ORDER BY deleted_at DESC;
    SQL

    results = ActiveRecord::Base.connection.execute(sql)

  end

  acts_as_geocodable address: {region: :region, street: :address, locality: :city, postal_code: :zip}

  has_many :contact_ratings
  has_many :ratings, :through => :contact_ratings
  has_many :jobs, dependent: :destroy
  has_many :communications, :through => :jobs
  has_many :appointments, :through => :jobs
  has_many :proposals, :through => :jobs

  accepts_nested_attributes_for :communications
  accepts_nested_attributes_for :jobs

  acts_as_tenant :organization

  validates_presence_of :first_name, :last_name, :email, :phone, :address, :zip, :city
  validates :email, :email => true
  before_save :set_defaults

  def set_defaults
    self.country ||= "United States"
  end

  def geocode_reliable?
    attach_geocode if geocode.nil?
    geocode.try(:precision) == :locality
  end

  def has_lead_source?
    jobs.where('lead_source_id IS NOT NULL').any?
  end

  def lead_source
    jobs.where('lead_source_id IS NOT NULL').order(:updated_at).first.lead_source
  end

  def lead?
    !jobs.empty?
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def backwards_name
    return (self.first_name || self.last_name).to_s unless self.first_name.present? && self.last_name.present?
    "#{self.last_name}, #{self.first_name}"
  end

  def name_and_address
    "#{backwards_name} - #{condensed_address}"
  end

  def full_address
    [address, address2, city, region, zip].select { |c| c.present? }.join(', ')
  end

  def condensed_address
    [address, city, zip].select { |c| c.present? }.join(', ')
  end

  def minimized_condensed_address
    [address, city].select { |c| c.present? }.join(', ')
  end

  def minimum_address
    [address, city].select { |c| c.present? }.join(', ')
  end

  def has_address?
    self.address.present? && self.city.present? && self.region.present?
  end

  def map_url
    "https://maps.google.com/?q=#{self.full_address}"
  end

  def map_data
    {
      :name => name,
      :lat => latitude,
      :lon => longitude,
      :show_url => Rails.application.routes.url_helpers.contact_url(self),
      :address => self.full_address
    }
  end

  def timezone
    if time_zone.present?
      from_active_support_time_zone time_zone
    elsif geocode.present?
      Timezone::Zone.new :latlon => [latitude, longitude]
    else
      from_active_support_time_zone organization.time_zone
    end
  end

  def active_support_time_zone
    ActiveSupport::TimeZone.new timezone.active_support_time_zone
  end

  private
  def from_active_support_time_zone zone
    Timezone::Zone.from_active_support ActiveSupport::TimeZone::MAPPING.fetch(zone)
  end
  def latitude
    geocode.try(:latitude)
  end
  def longitude
    geocode.try(:longitude)
  end
end

# == Schema Information
#
# Table name: contacts
#
#  id              :integer          not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  phone           :string(255)
#  email           :string(255)
#  address         :string(255)
#  address2        :string(255)
#  city            :string(255)
#  region          :string(255)
#  zip             :string(255)
#  country         :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#  company         :string(255)
#  deleted_at      :datetime
#
