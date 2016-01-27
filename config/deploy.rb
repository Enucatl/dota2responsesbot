# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'dota2responses'
set :repo_url, 'https://github.com/Enucatl/dota2responsesbot.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/dota2responsesbot/dota2responsesbot'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
#set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
#
#set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :default_env, { path: "$HOME/.rvm/bin:$PATH" }

# how many old releases do we want to keep
set :keep_releases, 5

# which config files should be made executable after copying
# by deploy:setup_config
#set(:executable_config_files, %w(unicorn_init.sh))

namespace :deploy do

  desc 'Restart application'

  after :publishing, :restart

  # override default tasks to make capistrano happy
  desc "Start unicorn"
  task :start do
    on roles(:app) do
      within current_path do
        execute "mkdir -p #{shared_path}/tmp/pids"
        execute :bundle, "exec unicorn -c #{current_path}/config/unicorn.rb -E production -D"
      end
    end
  end

  desc "Kick unicorn"
  task :restart do
    on roles :app do
      execute "kill -USR2 `cat #{shared_path}/tmp/pids/unicorn.pid`"
    end
  end

  desc "Kill a unicorn"
  task :stop do 
    on roles :app do
      execute "kill -QUIT `cat #{shared_path}/tmp/pids/unicorn.pid`"
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      #within release_path do
      #execute :rake, 'cache:clear'
      #end
    end
  end

end
