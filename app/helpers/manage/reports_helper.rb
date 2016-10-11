module Manage::ReportsHelper
  def percent_of_job_estimate(val, collected)
    if val && val < 0
      number_to_percentage(0, precision: 0)
    elsif collected && collected > 0
      number_to_percentage(val / collected * 100, precision: 0)
    else
      ''
    end
  end
end
