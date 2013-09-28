set :application, "maisarvoresdashboard"
set :repository,  "https://github.com/alvarowolfx/Dashboard-Mais-Arvores.git"
set :scm, :git
set :deploy_to, "/home/alvarowolfx/webapps/maisarvoresdashboard"

role :web, "alvarowolfx.webfactional.com"                          
role :app, "alvarowolfx.webfactional.com"
role :db,  "alvarowolfx.webfactional.com", :primary => true

set :user, "alvarowolfx"
set :scm_username, "alvarowolfx"
set :use_sudo, false
default_run_options[:pty] = true

namespace :deploy do
  desc "Restart nginx"
  task :restart do
    run "#{deploy_to}/bin/restart"
  end
end
