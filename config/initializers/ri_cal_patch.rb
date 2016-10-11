# There is a bug in the ri_cal gem that causes x properties to have an extra
# colon, which leads to calendar names starting with a colon.
#
# Found this fix in the pull request thread
class RiCal::Component::Calendar
  def export_x_properties_to(export_stream) #:nodoc:
    x_properties.each do |name, props|
      props.each do | prop |
        export_stream.puts("#{name}#{prop}")
      end
    end
  end
end
