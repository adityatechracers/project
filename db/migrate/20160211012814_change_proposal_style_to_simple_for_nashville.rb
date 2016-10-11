class ChangeProposalStyleToSimpleForNashville < ActiveRecord::Migration
  def change
    sql = "UPDATE organizations SET proposal_options = '{\"logo\": false}' WHERE id = 495;"
    ActiveRecord::Base.connection.execute(sql)
  end
end
