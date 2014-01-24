# Bundler tasks
require 'bundler/capistrano'
require 'capistrano_colors'
require File.expand_path('sexy_settings_config', File.dirname(__FILE__))

set :application, API.settings.application
set :repository,  "https://github.com/romikoops/howitzer_stat.git"
set :domain, API.settings.domain
set :deploy_via, :remote_cache
set :scm, :git

# do not use sudo
set :use_sudo, false
set(:run_method) { use_sudo ? :sudo : :run }

# This is needed to correctly handle sudo password prompt
default_run_options[:pty] = true

set :user, API.settings.user
set :group, user
set :runner, user
set :ssh_options, { :forward_agent => true }

role :web, domain
role :app, domain
role :db,  domain, :primary => true
set :rails_env, "production"
set :keep_releases, 5

# Where will it be located on a server?
set :deploy_to, API.settings.deploy_to
set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

after "deploy:setup", :roles => :app do
  run "mkdir -p #{deploy_to}/shared/config"
end

before 'deploy:create_symlink', :roles => :app do
  run "ln -s #{deploy_to}/shared/config/custom.yml #{current_release}/config/custom.yml"
end

# Unicorn control tasks
namespace :deploy do
  task :restart do
    run "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
  end
  task :start do
    run "cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  end
  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
end