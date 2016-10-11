# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :bootstrap, :tag => 'div', :class => 'control-group form-group clearfix', :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, :wrap_with => {:class=>"col-md-4 control-label"}
    b.wrapper :tag => 'div', :class => 'controls col-md-8' do |ba|
      ba.use :input
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end

  config.wrappers :flexible, :tag => 'div', :class => 'control-group form-group clearfix', :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, :wrap_with => {:class=>"control-label"}
    b.wrapper :tag => 'div', :class => 'controls col-md-8' do |ba|
      ba.use :input
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end

  config.wrappers :simple, :tag => 'div', :class => 'control-group form-group clearfix', :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, :wrap_with => {:class=>"m-b-xs"}
    b.wrapper :tag => 'div', :class => 'controls' do |ba|
      ba.use :input
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end

  config.wrappers :prepend, :tag => 'div', :class => "control-group form-group clearfix", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, :wrap_with => {:class=>"col-md-4 control-label"}
    b.wrapper :tag => 'div', :class => 'controls col-md-8' do |input|
      input.wrapper :tag => 'div', :class => 'input-prepend input-group' do |prepend|
        prepend.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    end
  end

  config.wrappers :prepend_simple, :tag => 'div', :class => "control-group form-group clearfix", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, :wrap_with => {:class=>"col-xs-12"}
    b.wrapper :tag => 'div', :class => 'controls col-xs-12' do |input|
      input.wrapper :tag => 'div', :class => 'input-prepend input-group' do |prepend|
        prepend.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    end
  end

  config.wrappers :append, :tag => 'div', :class => "control-group form-group clearfix", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, :wrap_with => {:class=>"col-md-4 control-label text-right"}
    b.wrapper :tag => 'div', :class => 'controls col-md-8' do |input|
      input.wrapper :tag => 'div', :class => 'input-append input-group' do |append|
        append.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    end
  end

  config.wrappers :inline_checkbox, :tag => 'div', :class => 'control-group form-group clearfix', :error_class => 'error' do |b|
    b.use :html5
    b.wrapper :tag => 'div', :class => 'controls col-md-8 col-md-offset-4 checkbox' do |ba|
      ba.use :label_input
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end

  config.wrappers :checkbox, :tag => 'div', :class => 'control-group form-group clearfix', :error_class => 'error' do |b|
    b.use :html5
    b.use :label, :wrap_with => {:class=>"col-md-4 control-label text-right"}
    b.wrapper :tag => 'div', :class => 'controls col-md-8 checkbox' do |ba|
      ba.wrapper :tag => 'label', class: 'checkbox checkbox-inline' do |bb|
        bb.use :input
      end
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-inline help-aside' }
    end
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end
