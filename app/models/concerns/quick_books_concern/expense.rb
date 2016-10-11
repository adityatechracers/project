module QuickBooksConcern::Expense
  def qb_update_description update
    do_update :description, update
  end   
  def qb_update_amount update
    do_update :amount, update
  end   
  private 
  def do_update column, value 
    update_attribute column, value
  end   
end   