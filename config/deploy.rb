set :application, "utunes"
set :repository,  "ol@central-services.dnsdojo.org:/pub/utunes.git"
set :deploy_to,   "/var/www/utunes_scm"
# set :deploy_to,   "/Users/ol/utunes"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set  :domain, "central-services.dnsdojo.org"
# set  :domain, "localhost"
role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# ssh_options[:forward_agent] = true
default_run_options[:pty] = true
# default_run_options[:shell] = false
set :deploy_via, :remote_cache
set :use_sudo, false
set :runner, "www-data"
set :user, "www-data"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end


# optional task to reconfigure databases
after "deploy:update_code", :configure_database
desc "copy database.yml into the current release path"
task :configure_database, :roles => :app do
  db_config = "#{deploy_to}/config/database.yml"
  mail_config = "#{deploy_to}/config/mail_config.rb"

  run "cp #{db_config} #{release_path}/config/database.yml"
  run "cp #{mail_config} #{release_path}/config/mail_config.rb"
  
end

