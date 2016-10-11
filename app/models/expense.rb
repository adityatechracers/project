# == Schema Information
#
# Table name: expenses
#
#  id                  :integer          not null, primary key
#  job_id              :integer
#  organization_id     :integer
#  amount              :decimal(9, 2)
#  description         :text
#  date_of_expense     :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  deleted_at          :datetime
#  user_id             :integer
#  expense_category_id :integer
#  vendor_category_id  :integer
#

class Expense < ActiveRecord::Base
  attr_accessible :amount, :date_of_expense, :description, :job_id, :organization_id, :user_id, :expense_category_id, :vendor_category_id
  belongs_to :job
  belongs_to :user
  belongs_to :expense_category
  belongs_to :vendor_category

  acts_as_tenant :organization

  validates :job_id, presence: true
  validates :amount, presence: true, numericality: true

  scope :from_time_range, lambda { |s, e| where('date_of_expense BETWEEN ? AND ?', s, e).order('date_of_expense ASC') }
  scope :created_by_employee, lambda { |e| where(user_id: e.id) }
  scope :for_job, lambda { |j| where(job_id: j.id) }
  scope :in_range, lambda { |range| where(date_of_expense: range) }

  scope :major_expenses, ->{ where('expense_category_id IN (?)', ExpenseCategory.major.pluck(:id)) }
  scope :minor_expenses, ->{ where('expense_category_id IS NULL OR expense_category_id NOT IN (?)', ExpenseCategory.major.pluck(:id)) }

  include QuickBooksConcern::Expense

  class << self
    def breakdown_by_employee(employees)
      employees
        .map { |employee| [employee.name, where(user_id: employee.id).sum(:amount)] }
        .push( ['Other', where('user_id is null or user_id not in (?)', employees.map(&:id)).sum(:amount)] )
    end

    def breakdown_by_job(jobs)
      jobs
        .map { |job| [job.full_title, where(job_id: job.id).sum(:amount)] }
        .push( ['Other', where('job_id not in (?)', jobs.map(&:id)).sum(:amount)] )
    end

    def breakdown_by_category(categories)
      categories
        .map { |cat| [cat.name, where(expense_category_id: cat.id).sum(:amount)] }
        .push( ['Other', where('expense_category_id is null or expense_category_id not in (?)', categories.map(&:id)).sum(:amount)] )
    end

    def profit_breakdown(jobs)
      data = breakdown_by_category(ExpenseCategory.major)
      data << [ 'Profit', [jobs.sum(&:profit), 0].max ]
      data
    end
  end

  def set_crew_labor_attributes(job)
    job_amount = job.estimated_amount.present? && job.estimated_amount > 0 ? job.estimated_amount : job.calculated_amount

    self.job_id = job.id
    self.expense_category = job.organization.expense_categories.find_by_name('Labor')
    self.amount = job_amount * job.crew_wage_rate
    self.description = %{
      This expense was automatically generated using the crew wage rate of \
      #{number_to_percentage(job.crew_wage_rate * 100, precision: 2)} and \
      job amount of #{number_to_currency(job_amount)}.
    }
  end

  def amount=(num)
    self[:amount] = num.to_s.scan(/\b-?[\d.]+/).join.to_f
  end
end
