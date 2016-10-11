class DatePickerInput < SimpleForm::Inputs::StringInput
  def input_html_options
    res = super
    input_html_classes << "date_picker"
    value = object.send(attribute_name) if object.respond_to? attribute_name
    res[:value] = I18n.localize(value) if value.present?
    res
  end
end
