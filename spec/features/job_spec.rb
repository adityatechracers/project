require 'spec_helper'

describe 'jobs and proposals workflow' do

  context 'with a proposal with an amount' do
    let(:active_p) { create(:proposal, :with_job, amount: 1000.0) }
    let(:accepted_p) { create(:proposal, :with_job, amount: 1000.0, proposal_state: 'Accepted') }

    it 'should equal the jobs estimated amount' do
      active_p.job.estimated_amount.should == 1000.0
    end

    it 'should adjust the jobs estimated amount with change orders' do
      co = create(:change_order,
                   proposal_id: accepted_p.id,
                   proposal_amount_change: 50,
                   user_id: accepted_p.sales_person_id,
                   change_description: "NOT BLANK")
      p.job.estimated_amount.should == 1050.0
    end

  end

end
