# encoding: UTF-8

module ApplicationHelper

  def format_amount(amount)
    splited_amount = amount.split('.')
    if splited_amount[1] != '00'
      splited_amount.join('.');
    else
      splited_amount[0];
    end
  end

  def hform_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.deep_merge({:html => {:class => "form-horizontal"}, :builder => HorizontalFormBuilder, defaults: { input_html: { class: 'form-control' }, label_html: { class: 'control-label' } }})), &block)
  end

  def form_group (group_label, required = false, &block)
    content_tag :div, class: 'form-group control-group clearfix required' do
      label_tag(nil, class: 'string required control-label col-md-4 control-label') do
        if group_label && required
          '<abbr title="required">* </abbr>'.html_safe() + group_label
        elsif group_label && !required
          group_label
        end
      end + \
      content_tag(:div, class: 'controls col-md-8') do
        yield
      end
    end
  end

  def file_input_group (form_f, name, file_format)
    content_tag :div, class: 'control-group' do
      content_tag :div, class: 'input-group' do
        text_field_tag(name, nil, class: "form-control", readonly: true, type: "text", placeholder: 'example.' + file_format) + \
        content_tag(:span, class: 'input-group-btn') do
          label_tag(nil, class: 'btn btn-primary btn-file') do
            t('shared.choose_file').html_safe + \
            form_f.file_field(name).html_safe
          end
        end
      end
    end
  end

  def button_radio (field_name, choices = [])
    content_tag :div, class: 'btn-group', data: { toggle: 'buttons' } do
      button_string = ""
      choices.each do |button|
        button_string += "<label class='btn btn-default'>"
        button_string += "<input type='radio' name='#{field_name}' id='#{button}' value='#{button}' autocomplete='off'>"
        button_string += "#{button}".humanize.capitalize
        button_string += "</label>"
      end
      button_string.html_safe
    end
  end

  def destroy_link_to(path, options, &block)
    defaults = {
      method: :delete,
      confirm: '',
      "data-confirm-proceed" => t('shared.delete'),
      "data-confirm-proceed-class" => "btn-danger"
    }
    link_to path, defaults.merge(options) do
      block.call
    end
  end

  def plan_label_for(plan_name)
    plan_name ||= 'Cancelled'
    klass = case plan_name
            when 'Enterprise' then 'label-info'
            when 'Gold' then 'label-warning'
            when 'Bronze' then 'label-inverse'
            when 'Free' then 'label-important'
            when 'Cancelled' then 'label-important'
            when 'Expired' then 'label-important'
            else nil
            end
    content_tag(:span, plan_name, :class => "label #{klass}")
  end

  def bool_label(bool)
    content_tag :span, bool ? 'Yes' : 'No',
      :class => "label #{bool ? 'label-success' : 'label-important'}"
  end

  def on_tab?(tab)
    !!(request.fullpath.split("/")[1] =~ tab)
  end

  def active_subnav(tab)
    on_tab?(tab) ? 'active' : ''
  end

  def active_class_for_params(active_params)
    if params.to_set.superset?(active_params.to_set)
      'active'
    else
      ''
    end
  end

  def active_filter_for(name, filter_name, options={})
    filter = filter_name.to_s
    if options[:root]
      options = {:active => /^(?!.*filter=).*$/}.deep_merge(options)
      active_link_to(name, filter, options)
    else
      options = {:active => /filter=#{filter}/}.deep_merge(options)
      active_link_to(name, params.merge(:filter => filter).except(:page), options)
    end
  end

  def date_range_filter_button
    render :partial => "shared/date_range_filter_button"
  end

  def left_date_range_filter_button
    render :partial => "shared/left_date_range_filter_button"
  end
  
  def contact_link_with_popover(contact)
    data_options = {
      :toggle => 'popover',
      :title => "#{contact.name}<i class='icon-address-book pull-right'></i>",
      :trigger => 'hover',
      :html => true,
      :content => render(:partial => 'shared/contact_popover', :locals => {:contact => contact})
    }
    link_to contact.backwards_name, contact_path(contact), :data => data_options
  end

  def communication_history_item_with_popover(c, job=nil, placement="left")
    if job.nil?
      job = c.job
    elsif job.is_a? String
      placement = job
      job = c.job
    end
    data_options = {
      :toggle => 'popover',
      :title => c.type.underscore.split("_").join(" ").titleize+"<i class='icon-#{c.type=="CommunicationRecord" ? "history":"calendar-2"} pull-right'></i>",
      :trigger => 'hover',
      :html => true,
      :content => render(:partial => 'shared/communication_popover', :locals => {:c => c, :job => job}),
      :placement => placement
    }
    link_to c.summary, communications_path, :data => data_options
  end

  def communication_detail_popover(c,placement="left")
    c.details ||= "<i>No details were recorded regarding this communication.</i>"
    data_options = {
      :toggle => 'popover',
      :title => "Communication Details<i class='icon-#{c.type=="CommunicationRecord" ? "history":"calendar-2"} pull-right'></i>",
      :trigger => 'hover',
      :html => true,
      :content => c.details,
      :placement => "left"
    }
    link_to content_tag(:i,"",:class => 'icon-newspaper'), "#", :data => data_options, :style => "margin-left:5px;margin-right:5px;"
  end

  def job_link_with_popover(j,placement="left")
    data_options = {
      :toggle => 'popover',
      :title => "#{j.full_title} <i class='icon-paint-format pull-right'></i>",
      :trigger => 'hover',
      :html => true,
      :content => render(:partial => 'shared/job_popover', :locals => {:j => j}),
      :placement => placement
    }
    link_to j.full_title, job_path(j), :data => data_options
  end

  def split_button_filter(label, param, droptions={}, droptions_key=:id, droptions_value=:name, options={})
    if droptions_key.is_a? Hash
      options = droptions_key.dup
      droptions_key = :id
      droptions_value = :name
    end
    if droptions_value.is_a? Hash
      options = droptions_value.dup
      droptions_value = :name
    end

    klass = if droptions.any? then droptions.first().class else nil end
    droptions = droptions.any? ? droptions.map {|opt| if opt.is_a? Array then [opt[0].to_s,opt[1].to_s] elsif opt.is_a? String or opt.is_a? Integer then [opt.to_s,opt.to_s] else [opt.send(droptions_key),opt.send(droptions_value)] end} : []
    value = if params.has_key?(param) then klass.find(params[param]).send(droptions_key) else "" end
    options = {:data => {:origtext => label, :value => value}}.deep_merge!(options)
    render :partial => "shared/split_button_filter", :locals => {:label => label, :param => param, :droptions => droptions, :droptions_key => droptions_key, :droptions_value => droptions_value, :klass => klass, :value => value, :options => options}
  end

  def breadcrumbs(*args)
    crumbs = args.map do |arg|
      arg.is_a?(String) ? arg : link_to(arg.keys.first, arg.values.first, :class => 'breadcrumb-link')
    end
    crumbs.join content_tag(:span, ' / '.html_safe, :class => 'breadcrumb-divider')
  end

  def attachment_url(file, style = :original)
    "#{request.protocol}#{request.host_with_port}#{file.url(style)}"
  end

  def pdf_image_tag(image, options = {})
    if image =~ /system/
      options[:src] = "file://#{File.expand_path(Rails.root)}/public#{image}"
    else
      base = File.basename(image)
      options[:src] = "file://#{File.expand_path(Rails.root)}/app/assets/images/#{base}"
    end
    tag(:img, options)
  end

  def chartkick_opts(opts={})
    {:backgroundColor => "transparent",:fontName => "Lato"}.deep_merge!(opts)
  end

  def proposal_signature_indicator(p)
    out = "<span class='label"
    out += " label-success" if p.customer_signed?
    out += "'>"
    out += if p.customer_signed? then "Customer signed #{time_ago_in_words(p.customer_sig_datetime)} ago" else "Customer has not yet signed" end
    out += "</span>"
    out += "<br />"
    out += "<span class='label"
    out += " label-success" if p.contractor_signed?
    out += "'>"
    out += if p.contractor_signed? then "Contractor signed #{time_ago_in_words(p.contractor_sig_datetime)} ago" else "Contractor has not yet signed" end
    out += "</span>"
    out
  end

  def cb(pagename, itemname, tag = :div, tag_options={})
    # Fetch page
    page = Page.find_by_name(pagename)
    return if page.blank?

    # Fetch or create pageitem
    item_params = {:page_id => page.id, :name => itemname}
    matches = PageItem.where(item_params)
    item = if matches.any? then matches.first() else PageItem.new(item_params) end

    # Build output tag
    item.content ||= item.present? ? item.content : "<p>This block is content managed!<br />Edit item \"#{itemname}\" of page \"#{pagename}\" to add content here.</p>"
    tag_options = tag_options.deep_merge({:id => "pageitem-#{item.id}", :data => {:pageitem => item.id}})
    tag_options[:contenteditable] = "true" if user_signed_in? and current_user.is_admin?
    tag_options[:class] = (tag_options.has_key?(:class) ? "#{tag_options[:class]} ":"") + "cms-block"

    content_tag(tag, item.content, tag_options, false)
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to(params.merge(sort: column, direction: direction), class: css_class) do
      content = content_tag(:span, title.html_safe)
      content << content_tag(:small, ' ▲') if css_class && direction == 'desc'
      content << content_tag(:small, ' ▼') if css_class && direction == 'asc'
      content
    end
  end

  # Remove any leading protocol so that the url is suitable for display.
  def url_without_protocol(url)
    url.gsub(/^http:\/\/s?/, '')
  end

  # If a protocol is set, use it, otherwise prepend http://
  def url_with_protocol(url)
    if url =~ /^http:\/\/s?/
      url
    else
      "http://#{url}"
    end
  end

  def get_profile_image
    current_user.image_url.present? ? current_user.image_url : 'profile.jpg'
  end 

  def get_priority_range(template)
    category = template.name.split("-").first  if template
    if category.present?
      category = (category == "appointment") ? "lead" : category
      email_templates = EmailTemplate.where(organization_id: nil, lang: "en") 
      email_templates = (category == "lead") ? email_templates.lead : email_templates.by_category(category) if email_templates 
      range =  email_templates.present? ? 1..email_templates.size : 0
    else
      range = 0
    end
    range  
  end 
end
