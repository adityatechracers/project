OmniAuth.config.full_host = case Rails.env
  when 'development'  then 'http://localhost:3000'
  when 'theme'        then 'https://corkcrmtheme.herokuapp.com'
  when 'staging'      then 'https://45.79.187.230'
  when 'production'   then 'https://www.corkcrm.com'
end