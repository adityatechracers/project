namespace :db do
  task :pull do
    system 'bundle exec rake db:drop'
    system 'heroku pg:pull HEROKU_POSTGRESQL_ROSE_URL corkcrm_development'
  end
end
