# == Schema Information
#
# Table name: email_templates
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string(255)
#  subject         :text
#  body            :text
#  enabled         :boolean
#  master          :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  description     :text
#  lang            :string(255)      default("en"), not null
#  mail_to_cc      :string(255)
#

class EmailTemplate < ActiveRecord::Base
  attr_accessible :priority, :body, :enabled, :id, :organization_id, :subject, :name, :master, :available_tokens, :mail_to_cc

  has_paper_trail
  has_one :email_template_token_set, :primary_key => 'name', :foreign_key => 'template_name'

  acts_as_tenant :organization


  validates :body, :liquid => true
  validates :subject, :body, presence: true

  TEMPLATE_CATEGORY = ["lead", "proposal", "job", "stripe", "trial", "email", "expired", "test", "cancelled paid account"]

  scope :by_category, ->(category) { where('name like ?', "%#{category}%")}
  scope :lead, -> { where("name ILIKE ANY ( array[?] )", ["%lead%", "%appointment%"])}
  scope :by_organization, ->(id) {where(:organization_id => id)}

  before_save :ensure_formatting_correct_mail_to_cc
  after_update :update_priority
  class << self

    def render_body(name, token_hash, options)
      render_item(name, token_hash, :body, options)
    end

    def render_subject(name, token_hash, options)
      render_item(name, token_hash, :subject, options)
    end

    def template_enabled?(name)
      EmailTemplate
        .where(enabled: true, lang: template_language)
        .find_by_name(name).present?
    end

    def template_by_category(templates)
      template = {}
      EmailTemplate::TEMPLATE_CATEGORY.each do |category|
        if category == EmailTemplate::TEMPLATE_CATEGORY[0]
          template["#{category}"] = templates.lead.order(:priority)
        else
          template["#{category}"] = templates.by_category(category).order(:priority)
        end
      end
      template
    end

    private

    def render_item(name, token_hash, item, options)
      lang = options[:lang] || template_language
      template = EmailTemplate
        .where(enabled: true, lang: lang)
        .find_by_name(name)
      raise "EmailTemplate with name '#{name}' and language '#{lang}' does not exist or is not enabled" unless template.present?
      Liquid::Template.parse(template.send(item)).render(token_hash)
    end

    def template_language
      ActsAsTenant.current_tenant.try(:language) || User::Language::ENGLISH
    end

  end

  def check_for_master
    if self.master
      errors.add_to_base('master templates cannot be deleted')
      return false
    end
  end
  private
  def ensure_formatting_correct_mail_to_cc
    self.mail_to_cc = self.mail_to_cc.gsub(/,/,' ').split.map {|cc|cc.squish}.join(',') if self.mail_to_cc.present?
  end

  def update_priority
    if self.priority_changed?
      email_templates = EmailTemplate.where(name: self.name)
      email_templates.update_all(priority: self.priority) if email_templates.present?
    end
  end
end
