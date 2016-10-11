class ChangeOldImageHost < ActiveRecord::Migration
  def up
    sql = "UPDATE proposal_section_responses SET description = REPLACE(description, 'http://www.corkcrm.com', 'http://app.corkcrm.com') WHERE description LIKE '%http://www.corkcrm.com%';"
    ActiveRecord::Base.connection.execute(sql)
  end

  def down
  end
end
