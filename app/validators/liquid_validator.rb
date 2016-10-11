class LiquidValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    Liquid::Template.parse(value) if value.present?
  rescue Liquid::SyntaxError => e
    record.errors[attribute] << (options[:message] || e.message || "failed Liquid validation.")
  end

end
