set :user, "corkcrm"   # username on remote server

set :application, "app.corkcrm.com"

set :whenever_environment, -> { fetch :stage }
set :whenever_identifier, -> { "#{fetch :application}_#{fetch :stage}" }

# MODIFY THIS with your ruby version
set :rvm_ruby_string, 'ruby-2.1.10'

# MODIFY THIS with your real git repo
set :repo_url, "git@github.com:corkcrm/corkcrm.git"

#SYMLINKS
append :linked_files, "config/database.yml", "config/stripe.yml", "config/mandrill.yml", "config/quick_books.yml"
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'scripts', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

set :use_sudo, false
set :scm, :git
set :scm_verbose, true
set(:deploy_to) { "/home/#{fetch :user}/public_html/#{fetch :application}" }

# Skip migration if files in db/migrate were not modified
set :conditionally_migrate, true

## ssh 
set :ssh_options, {
  forward_agent: true
}

set :keep_assets, 3

SSHKit.config.command_map[:rake]  = "bundle exec rake" 
SSHKit.config.command_map[:rails] = "bundle exec rails"

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join("tmp/restart.txt")
    end
  end
  
  task :seed_fu do
     %{cd #{fetch :release_path} && bundle exec rake RAILS_ENV=#{fetch :rails_env} db:seed_fu}
  end
  
  after "deploy", "deploy:seed_fu"
  after :finished, 'deploy:restart'
end 


