class OwnerValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if record.organization.present? && record.organization.owner == record && value != 'Owner' && value != 'Admin'
      record.errors[attribute] << (options[:message] || "This user's organization must have at least one owner.")
    end
  end

end
