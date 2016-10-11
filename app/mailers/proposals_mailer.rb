class ProposalsMailer < BaseMailer
  add_template_helper(MailerHelper)
  add_template_helper(ApplicationHelper)
  add_template_helper(ProposalsHelper)

  def proposal_contract(proposal)
    @proposal = proposal
    @contact = @proposal.job.contact
    @title = @proposal.title
    @proposal_options = { logo: true }
    pdf_template = case @proposal.organization.proposal_style
                   when Organization::ProposalStyle::SIMPLE then 'contract_simple.pdf.haml'
                   when Organization::ProposalStyle::CORKCRM then 'contract.pdf.haml'
                   else raise 'Invalid or unsupported proposal style'
                   end
    attachments["#{proposal.pdf_name}-contract.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(
        pdf: proposal.pdf_name,
        template: "proposals/#{pdf_template}",
        layout: 'layouts/pdf.html.haml',
        page_size: @proposal.organization.proposal_paper_size
      )
    )
    mail_templated('proposal-accepted', tokens(proposal),
                   to: self.class.contacts(proposal),
                   from: self.class.organization_from_address,
                   reply_to: @proposal.sales_person.email)
  end

  def proposal(prop)
    @proposal = prop
    @contact = @proposal.job.contact
    @title = @proposal.title
    @proposal_options = { logo: true }
    pdf_template = case @proposal.organization.proposal_style
                   when Organization::ProposalStyle::SIMPLE then 'show_simple.pdf.haml'
                   when Organization::ProposalStyle::CORKCRM then 'show.pdf.haml'
                   else raise 'Invalid or unsupported proposal style'
                   end
    attachments["#{@proposal.pdf_name}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(
        pdf: @proposal.pdf_name,
        template: "proposals/#{pdf_template}",
        layout: 'layouts/pdf.html.haml',
        page_size: @proposal.organization.proposal_paper_size
      )
    )
    mail_templated('proposal-issued', tokens(@proposal),
                         to: self.class.contacts(@proposal),
                       from: self.class.organization_from_address,
                   reply_to: @proposal.sales_person.email)
  end

  def issued_2_day_reminder(proposal)
    mail_templated('proposal-issued-2-day-reminder', tokens(proposal),
                         to: proposal.job.contact.email,
                       from: self.class.organization_from_address,
                   reply_to: proposal.sales_person.email)
  end

  def issued_1_week_reminder(proposal)
    mail_templated('proposal-issued-1-week-reminder', tokens(proposal),
                         to: proposal.job.contact.email,
                       from: self.class.organization_from_address,
                   reply_to: proposal.sales_person.email)
  end

  def issued_1_month_reminder(proposal)
    mail_templated('proposal-issued-1-month-reminder', tokens(proposal),
                         to: proposal.job.contact.email,
                       from: self.class.organization_from_address,
                   reply_to: proposal.sales_person.email)
  end

  def issued_2_month_reminder(proposal)
    mail_templated('proposal-issued-2-month-reminder', tokens(proposal),
                         to: proposal.job.contact.email,
                       from: self.class.organization_from_address,
                   reply_to: proposal.sales_person.email)
  end

  def issued_3_month_reminder(proposal)
    mail_templated('proposal-issued-3-month-reminder', tokens(proposal),
                         to: proposal.job.contact.email,
                       from: self.class.organization_from_address,
                   reply_to: proposal.sales_person.email)
  end

  def contract_signed_confirmation(proposal)
    mail_templated('proposal-contract-signed-confirmation', tokens(proposal),
                         to: proposal.job.contact.email,
                       from: self.class.organization_from_address,
                   reply_to: proposal.sales_person.email)
  end

  def contract_signed_notification(proposal)
    recipients = [proposal.contractor.try(:email),
                  proposal.sales_person.try(:email)].compact.uniq
    mail_templated('proposal-contract-signed-notification', tokens(proposal),
                         to: recipients,
                       from: self.class.organization_from_address,
                   reply_to: proposal.sales_person.email)
  end

  def change_order_notification(proposal, change_order)
    change_order_tokens = tokens(proposal).merge(
      'change_order_summary'         => change_order.summary,
      'previous_proposal_amount'     => number_to_currency(change_order.original_proposal.amount),
      'previous_budgeted_hours'      => change_order.original_proposal.budgeted_hours,
      'previous_expected_start_date' => I18n.l(change_order.original_proposal.expected_start_date),
      'previous_expected_end_date'   => I18n.l(change_order.original_proposal.expected_end_date),
      'current_proposal_amount'      => number_to_currency(proposal.amount),
      'current_budgeted_hours'       => proposal.budgeted_hours,
      'current_expected_start_date'  => I18n.l(proposal.expected_start_date),
      'current_expected_end_date'    => I18n.l(proposal.expected_end_date)
    )

    mail_templated('proposal-change-order-notification', change_order_tokens,
                         to: proposal.job.contact.email,
                         cc: proposal.sales_person.try(:email),
                       from: self.class.organization_from_address,
                   reply_to: proposal.sales_person.try(:email))
  end

  def self.contacts(proposal)
    [ proposal.contractor.try(:email),
      proposal.sales_person.try(:email),
      proposal.job.contact.try(:email) ].compact.uniq
  end

  private

  def tokens(proposal)
    org = proposal.organization
    {
      'prospect_first_name'  => proposal.job.contact.first_name,
      'prospect_last_name'   => proposal.job.contact.last_name,
      'proposal_number'      => proposal.proposal_number,
      'proposal_url'         => Rails.application.routes.url_helpers.proposal_portal_url(proposal.guid),
      'proposal_portal_url'  => Rails.application.routes.url_helpers.proposal_portal_url(proposal.guid),
      'contract_portal_url'  => Rails.application.routes.url_helpers.contract_portal_url(proposal.guid),
      'your_billing_address' => org.address,
      'your_billing_city'    => org.city,
      'your_billing_state'   => org.region,
      'organization_name'    => org.name
    }
  end
end
