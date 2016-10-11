require "spec_helper"

describe StripeCallbacksController do
  before :each do
    ActionMailer::Base.deliveries = []

    @json = {
      data: {
        object: {
          customer: 'foo',
          plan: {
              :name => 'Gold'
          }
        }
      }
    }

    @request.env['devise.mapping'] = Devise.mappings[:user]
    Activity.should_receive(:create).once.and_return(true)

    @org = double 'organization'
    @org.stub(:id).and_return(42)
    @org.stub(:name).and_return('The Org')
    @org.stub(:language).and_return('en')
    @org.stub(:payment_succeeded!).and_return(true)
    @org.stub(:payment_failed!).and_return(true)
    @org.stub_chain(:owner, :email).and_return('test@example.com')
    Organization.stub(:find_by_stripe_customer_token).with('foo').and_return(@org)
  end

  def stub_email_templates(template_name, expected_tokens)
    EmailTemplate.stub(:template_enabled?).and_return(true)
    EmailTemplate.should_receive(:render_subject) do |name, tokens|
      name.should == template_name
      tokens.keys.should == expected_tokens
      'the subject'
    end

    EmailTemplate.should_receive(:render_body) do |name, tokens|
      name.should == template_name
      tokens.keys.should == expected_tokens
      'the body'
    end
  end

  describe 'invoice.payment_failed' do
    it 'sends email and responds ok' do
      @org.should_receive(:payment_failed!).once
      @json[:type] = 'invoice.payment_failed'
      stub_email_templates('stripe-invoice-payment-failed', ['organization_name'])

      post :create, @json

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == ['test@example.com']
      ActionMailer::Base.deliveries.last.body.should include('the body')
      ActionMailer::Base.deliveries.last.subject.should == 'the subject'
      response.should be_success
    end
  end

  describe 'invoice.payment_succeeded' do
    it 'sends email and responds ok' do
      @org.should_receive(:payment_succeeded!).once
      @json[:type] = 'invoice.payment_succeeded'
      @json[:data][:object][:total] = 1000
      stub_email_templates('stripe-invoice-payment-successful', ['organization_name', 'charge_total'])

      post :create, @json

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == ['test@example.com']
      ActionMailer::Base.deliveries.last.body.should include('the body')
      ActionMailer::Base.deliveries.last.subject.should == 'the subject'
      response.should be_success
    end
  end

  describe 'charge.succeeded' do
    it 'sends email and responds ok' do
      @org.should_receive(:payment_succeeded!).once
      @json[:type] = 'charge.succeeded'
      @json[:data][:object][:total] = 10000
      stub_email_templates('stripe-charge-successful', ['organization_name', 'charge_total'])

      post :create, @json

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == ['test@example.com']
      ActionMailer::Base.deliveries.last.body.should include('the body')
      ActionMailer::Base.deliveries.last.subject.should == 'the subject'
      response.should be_success
    end
  end

  describe 'charge.failed' do
    it 'sends email and responds ok' do
      @json[:type] = 'charge.failed'
      stub_email_templates('stripe-charge-failed', ['organization_name'])

      post :create, @json

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == ['test@example.com']
      ActionMailer::Base.deliveries.last.body.should include('the body')
      ActionMailer::Base.deliveries.last.subject.should == 'the subject'
      response.should be_success
    end
  end

  describe 'charge.dispute.created' do
    it 'sends email and responds ok' do
      @json[:type] = 'charge.dispute.created'
      stub_email_templates('stripe-charge-dispute-created', ['organization_name'])
      create(:user, role: 'Admin', super: true, email: 'admin@corkcrm.com', admin_receives_notifications: true)

      post :create, @json

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == ['admin@corkcrm.com']
      ActionMailer::Base.deliveries.last.body.should include('the body')
      ActionMailer::Base.deliveries.last.subject.should == 'the subject'
      response.should be_success
    end
  end

  describe 'customer.subscription.created' do
    it 'sends email and responds ok' do
      @json[:type] = 'customer.subscription.created'
      @json[:data][:object][:plan] = {:name => 'Silver'}
      stub_email_templates('stripe-subscription-created', ['organization_name', 'plan_name'])

      post :create, @json

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == ['test@example.com']
      ActionMailer::Base.deliveries.last.body.should include('the body')
      ActionMailer::Base.deliveries.last.subject.should == 'the subject'
      response.should be_success
    end
  end

  describe 'customer.subscription.updated' do
    it 'sends email and responds ok' do
      @json[:type] = 'customer.subscription.updated'
      @json[:data][:object][:plan] = {:name => 'Mercury'}
      stub_email_templates('stripe-subscription-updated', ['organization_name', 'plan_name'])

      post :create, @json

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == ['test@example.com']
      ActionMailer::Base.deliveries.last.body.should include('the body')
      ActionMailer::Base.deliveries.last.subject.should == 'the subject'
      response.should be_success
    end
  end

  describe 'customer.subscription.deleted' do
    it 'sends email and responds ok' do
      @json[:type] = 'customer.subscription.deleted'
      stub_email_templates('stripe-subscription-deleted', ['organization_name', 'plan_name'])

      post :create, @json

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == ['test@example.com']
      ActionMailer::Base.deliveries.last.body.should include('the body')
      ActionMailer::Base.deliveries.last.subject.should == 'the subject'
      response.should be_success
    end
  end

  describe 'customer.updated' do
    it 'creates a new AccountCredit record when the account balance has changed'
    it 'ignores the event when the account balance has not changed'
  end
end
