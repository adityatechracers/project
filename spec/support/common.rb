require 'spec_helper'
require 'rspec/expectations'

RSpec::Matchers.define :have_attributes do |expected|
  def normalize_values(actual_value, expected_value)
    # Convert actual to a Float if that's what we provided to test
    if actual_value.is_a?(BigDecimal) && expected_value.is_a?(Float)
      actual_value = actual_value.to_f
    end
    [actual_value, expected_value]
  end

  match do |actual|
    expected.keys.all? do |k|
      actual_value, expected_value = normalize_values(actual.attributes[k.to_s], expected[k])
      actual_value == expected_value
    end
  end

  failure_message_for_should do |actual|
    msg = ''
    expected.keys.each do |k|
      actual_value, expected_value = normalize_values(actual.attributes[k.to_s], expected[k])

      if actual_value != expected_value
        msg += "Attribute #{k.inspect} does not match:\n"
        msg += "\t#{actual_value.inspect} should equal #{expected_value.inspect}\n"
      end
    end
    msg
  end
end

module CommonHelpers
  def without_confirm_dialog
    page.execute_script %{
      $.rails.__allowAction = $.rails.allowAction;
      $.rails.allowAction = function() { return true; };
    }
    yield if block_given?
    page.execute_script("$.rails.allowAction = $.rails.__allowAction;")
  end
end
