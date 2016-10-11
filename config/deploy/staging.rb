set :stage, :staging
set :rvm_type, :user    # rvm single-user installs ($HOME/rvm)
server "45.79.187.230", user: fetch(:user), roles:[:app, :web, :db], primary: true
set :rails_env, "staging"
set :branch, ENV["REVISION"] || "theme-master" # git branch to use for deployments
