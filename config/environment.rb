# Load the rails application
require File.expand_path('../application', __FILE__)

Geocode.geocoder = Graticule.service(:google).new 'AIzaSyB-eZUrZPIvQCwJyqhmsPDHYuYwCDbQdoc'

# Initialize the rails application
Corkcrm::Application.initialize!
