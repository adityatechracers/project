include ActionView::Context

class HorizontalFormBuilder < SimpleForm::FormBuilder

  def control_group(label_name, attributes={}, &block)
    attributes[:class] += " control-group" if attributes[:class]
    attributes[:class] ||= "control-group"

    @template.content_tag(:div,attributes) do
      @template.label_tag('', label_name, {:class => "control-label col-sm-10"}) +
        @template.content_tag(:div, {:class => "controls col-sm-10"}, &block)
    end
  end

  def input(attribute_name, options = {}, &block)
    options[:input_html] ||= {}
    #options[:input_html].merge! class: 'span12'
    super
  end

  def submit(value=nil, options={})
    options[:class] = 'btn btn-success'
    "<div class='form-actions'>#{super}</div>".html_safe
  end

  def delete_btn(options={})
    options[:method] = "delete"
    options[:class] ||= "btn btn-danger"
    options[:confirm] ||= "Are you sure you want to delete this?"

    @template.link_to("Delete", "#", options)
  end

end
