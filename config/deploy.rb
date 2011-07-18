require 'bundler/capistrano'

set :application, "tatibot"

set :repository,  "git@github.com:alx/tatibot.git"
set :scm, :git

set :user, "user"
set :group, "group"
set :deploy_to, "/path/#{application}"

set :domain, "your_server_ip"
server domain, :app, :web
role :db, domain, :primary => true

task :link_shared_directories do     
  run "ln -s #{shared_path}/bot_config.yml #{release_path}/bot_config.yml"
  run "ln -s #{shared_path}/tatibot.db #{release_path}/tatibot.db"
  run "ln -s #{shared_path}/bot.rb.pid #{release_path}/bot.rb.pid"
end    

after "deploy:update_code", :link_shared_directories

