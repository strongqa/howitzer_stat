# We're using RVM on a server, need this.
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
#require 'rvm/capistrano'
#set :rvm_ruby_string, '1.9.3'
#set :rvm_type, :user

# Bundler tasks
require 'bundler/capistrano'
require 'capistrano_colors'

set :application, "howitzer_stat"
set :repository,  "https://github.com/romikoops/howitzer_stat.git"
set :domain, "strongqa.com"
set :deploy_via, :remote_cache
set :scm, :git

# do not use sudo
set :use_sudo, false
set(:run_method) { use_sudo ? :sudo : :run }

# This is needed to correctly handle sudo password prompt
default_run_options[:pty] = true

set :user, "deployer"
set :group, user
set :runner, user
set :ssh_options, { :forward_agent => true }

role :web, domain
role :app, domain
set :rails_env, "production"
set :keep_releases, 5

# Where will it be located on a server?
set :deploy_to, "/opt/www/#{application}"
set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

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