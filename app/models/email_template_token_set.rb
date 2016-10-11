class EmailTemplateTokenSet < ActiveRecord::Base
  serialize :available_tokens, JSON
end

# == Schema Information
#
# Table name: email_template_token_sets
#
#  id               :integer          not null, primary key
#  template_name    :string(255)
#  available_tokens :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
