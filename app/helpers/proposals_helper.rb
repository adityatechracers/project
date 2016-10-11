module ProposalsHelper
  def link_to_unless_print(is_print, *args)
    if is_print
      content_tag(:span, args[0], args.length == 3 ? args[2] : {})
    else
      link_to(*args)
    end
  end

  def proposal_status_indicator(proposal)
    label_type = case proposal.proposal_state
                 when 'Accepted' then 'success'
                 when 'Active' then 'info'
                 when 'Issued' then 'warning'
                 when 'Declined' then 'important'
                 end
    state = t("proposals.index.states.#{proposal.proposal_state.try(:downcase)}")
    content_tag(:span, state, class: "label label-#{label_type}")
  end

  def attachments_links(proposal)
    list = []
    proposal.proposal_files.each do |file|
      list << link_to(file.original_file_name, file.file_url) unless file.is_personal_proposal_file?
    end
    raw list.to_sentence
  end

  def format_created_at(v)
    "Created on " + v.created_at.strftime("%B #{v.created_at.day.ordinalize}, %Y by #{version_added_by(v)} at %l:%M%P")
  end

  def format_updated_at(v)
    "Updated on " + v.created_at.strftime("%B #{v.created_at.day.ordinalize}, %Y by #{version_added_by(v)} at %l:%M%P")
  end

  def format_issued_at(v)
    "Issued on " + v.created_at.strftime("%B #{v.created_at.day.ordinalize}, %Y by #{version_added_by(v)} at %l:%M%P")
  end

  def format_accepted_at(v)
    "Accepted on " + v.created_at.strftime("%B #{v.created_at.day.ordinalize}, %Y by #{version_added_by(v)} at %l:%M%P") 
  end

  def format_declined_at(v)
    "Marked as declined on " + v.created_at.strftime("%B #{v.created_at.day.ordinalize}, %Y by #{version_added_by(v)} at %l:%M%P")
  end

  def format_voided_at(version)
    "Voided on " + version.created_at.strftime("%B #{version.created_at.day.ordinalize}, %Y by #{version_added_by(version)} at %l:%M%P")
  end

  def check_issued(version)
    version.changeset.has_key? :proposal_state and version.changeset[:proposal_state].second == "Issued"
  end

  def check_accepted(version)
    version.changeset.has_key? :proposal_state and version.changeset[:proposal_state].second == "Accepted"
  end

  def check_voided(version)
    voided = true

    void_keys = [:proposal_state, :customer_sig_printed_name, :customer_sig,
      :customer_sig_user_id, :customer_sig_datetime, :contractor_sig_printed_name,
      :contractor_sig, :contractor_sig_user_id, :contractor_sig_datetime]

    void_keys.each do |k|
      if k == :proposal_state and version.changeset.key? k
        if version.changeset[k].second != "Active"
          voided = false
          break
        end
      elsif version.changeset.key? k
        if version.changeset[k].second.present?
          voided = false
          break
        end
      else
        voided = false
        break
      end
    end

    # void_values = true
    # version.changeset.values.each do |value|
    #   if !value.second.nil?
    #     void_values = false
    #     break
    #   end
    # end

    # void_keys.all? {|x| version.changeset.key? x} and void_values
    return voided
  end

  def check_declined(version)
    version.changeset.has_key? :proposal_state and version.changeset[:proposal_state].second == "Declined"
  end

  def version_added_by(v)
    if v.whodunnit.present?
      (User.find v.whodunnit).name
    else
      v.item.creator.name
    end
  end


end
