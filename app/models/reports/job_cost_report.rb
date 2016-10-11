# The JobCostReport class generates a dataset with job cost data for an
# organization for the given year, breaking the costs down by months.
#
# The data can be viewed as the organization total, or by job/crew.
class JobCostReport
  def initialize(organization, year)
    @organization, @year = organization, year
  end

  # These three

  def dataset_by_crew
    @organization.crews.map do |crew|
      {
        label: "#{crew.name} (#{@year})",
        months: Hash[report_months.map { |m| [I18n.l(m, format: '%B'), monthly_dataset_for_resource(crew, m)] }],
        total: totals_for_resource(crew)
      }
    end
  end

  def dataset_by_job
    # Only include 'relevant' jobs. See the criteria below for what that entails.
    jobs_for_reporting_year = @organization.jobs.select do |job|
      year_start = Date.new(@year)
      date_range = (year_start..year_start.end_of_year.end_of_month + 1.day)
      job.created_at.year == @year ||
        job.expenses.where(date_of_expense: date_range).any? ||
        job.payments.where(date_paid: date_range).any?
    end

    jobs_for_reporting_year.map do |job|
      {
        label: "#{job.full_title} (#{@year})",
        months: Hash[report_months.map { |m| [I18n.l(m, format: '%B'), monthly_dataset_for_resource(job, m)] }],
        total: totals_for_resource(job)
      }
    end
  end

  def dataset
    [
      {
        label: "Totals for #{@year}",
        months: Hash[report_months.map { |m| [I18n.l(m, format: '%B'), monthly_dataset_for_resource(@organization, m)] }],
        total: totals_for_resource(@organization)
      }
    ]
  end

  def totals_for_resource(resource)
    year_start = Date.new(@year)
    date_range = (year_start..year_start.end_of_year.end_of_month + 1.day)
    period_dataset_for_resource(resource, date_range)
  end

  def monthly_dataset_for_resource(resource, month)
    date_range = (month.beginning_of_month..month.end_of_month + 1.day)
    period_dataset_for_resource(resource, date_range)
  end

  # Expects to be given a resource that responds to :payments and :expenses,
  # along with a date range.
  def period_dataset_for_resource(resource, date_range)
    data = {}

    payments = resource.payments.in_range(date_range)
    expenses = resource.expenses.in_range(date_range)

    data['Payments'] = payments.sum(:amount)
    @organization.expense_categories.major.each do |ec|
      data["#{ec.name} Expenses"] = expenses.where(expense_category_id: ec.id).sum(:amount)
    end

    data['Other Expenses'] = expenses.minor_expenses.sum(:amount)
    data['Profit'] = data['Payments'] - expenses.sum(:amount)
    data
  end

  def report_months
    (1..12).map { |m| Date.new(@year, m) }
  end
end
