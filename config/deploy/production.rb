set :stage, :production
set :rvm_type, :user    # rvm single-user installs ($HOME/rvm)
server "app.corkcrm.com", user: fetch(:user), roles: [:app, :web, :db], primary: true
set :rails_env, "production"
set :branch, ENV["REVISION"] || "theme-master" # git branch to use for deployments
