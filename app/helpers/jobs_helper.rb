module JobsHelper
  def display_job_activity activity
    state = activity.data[:to]
    prefix = case state
    when  "Lead"
      "Marked as Lead"
    else
      state
    end
    by = ""
    culprit = activity.culprit
    date = activity.created_at.strftime("%m/%d/%Y")
    time = activity.created_at.strftime('%-l:%M%p')
    by = culprit.name if culprit.present?
    "#{prefix} on #{date} #{by} at #{time}"
  end

  def job_expected_start_date job
    job.proposal.expected_start_date
  end  

  def job_expected_end_date job
    job.proposal.expected_end_date
  end  

  def display_payment_log payment
    amount = payment.amount
    method = payment.payment_type
    date = payment.created_at.strftime("%m/%d/%Y")
    time = payment.created_at.strftime('%-l:%M%p')
    "$#{amount} paid by #{method} on #{date} at #{time}"
  end

  def display_expense_log expense
    amount = expense.amount
    category = expense.expense_category.try(:name) || "Unknown"
    date = expense.date_of_expense.try do |date|
      date.strftime("%m/%d/%Y")
    end || "N/A"   
    "$#{amount} created on #{date} category #{category}"
  end

  
  def display_job_entry_start_end_datetime entry
    format_job_entry_date_range entry.start_datetime, entry.end_datetime
  end
  def action_view_proposals_link(job, classname= "")
    accepted = job.proposals.accepted
    params = {job:job.id}
    if accepted.size > 1
      params = params.merge({filter:"accepted"})
    end
    link_to raw("<i class='fa fa-eye'></i>"), proposals_path(params), class: classname
  end
  def display_crews job
    out = ""
    job.crews.each do |crew|
      out << dot_label(crew)
    end
    out
  end

   def job_status_indicator(job)
    label_type = case job.status
                 when 'Unscheduled' then 'warning'
                 when 'Scheduled' then 'badge-success'
                 when 'Completed' then 'greyed-out'
                 when "Accepted" then 'Unscheduled'
                 end
    job_status = job.status.try(:downcase) == 'accepted' ? 'Unscheduled' :  job.status.try(:downcase)
    state = t("jobs.index.states.#{job_status}")
    content_tag(:span, state, class: "label #{label_type}")
  end

  def expected_timeframe(job)
    start_date = job.expected_start_date
    end_date = job.expected_end_date
    if start_date && end_date
      "#{l start_date} to #{l end_date}"
    elsif start_date
      "Starting #{l start_date}"
    elsif end_date
      "Ending #{l end_date}"
    else
      nil
    end
  end
  def format_job_entry_date_range start_date, end_date
    "#{entry_date_format start_date} to #{entry_date_format end_date}"
  end
  def entry_date_format date
    date.strftime('%A %-m/%d %l:%M%p')
  end
  def dot_label crew, options={wrap:true}
    label = crew.name
    color = crew.color
    span = "<span class='label #{options[:class]}' style='color:white;background-color:#{color}'>#{label}</span>"
    if options[:wrap]
       """<div class='crew'>
        #{span}
       </div>"""
    else
      span
    end
  end
end
