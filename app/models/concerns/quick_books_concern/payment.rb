module QuickBooksConcern::Payment
  def qb_update_notes update
    do_update :notes, update
  end   
  def qb_update_amount update
    do_update :amount, update
  end   
  private 
  def do_update column, value 
    update_attribute column, value
  end   
end   