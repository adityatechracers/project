module TimecardsHelper
  def state_label_class(timecard)
    case timecard.state
      when "Entered" then "info"
      when "Approved" then "warning"
      when "Paid" then "success"
    end
  end
end
