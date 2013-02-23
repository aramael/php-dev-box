# overwrite default php.ini with custom one
template "/etc/php5/conf.d/custom.ini" do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources("service[apache2]"), :delayed
end

# xdebug package
php_pear "xdebug" do
  action :install
end

# xdebug template
template "/etc/php5/conf.d/xdebug.ini" do
  source "xdebug.ini.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources("service[apache2]"), :delayed
end

# php5 mysql
package "php5-mysql" do
  action :install
  notifies :restart, resources("service[apache2]"), :delayed
end

# memcached
package "memcached"

# memcache
php_pear "memcache" do
  action :install
end

# disable default apache site
execute "disable-default-site" do
  command "sudo a2dissite default"
  notifies :reload, resources(:service => "apache2"), :delayed
end

# configure apache project vhost
web_app "project" do
  template "project.conf.erb"
  server_name node['hostname']
  server_aliases node['aliases']
  docroot "/vagrant/public"
  set_env node['set_env']
end

# install git
package "git-core"

# phpMyAdmin
script "install_phpmyadmin" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  rm -rf /tmp/phpMyAdmin*

  wget http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/3.5.0/phpMyAdmin-3.5.0-english.tar.gz
  tar -xzvf phpMyAdmin-3.5.0-english.tar.gz

  mkdir -p /var/www/phpmyadmin
  cp -R /tmp/phpMyAdmin-3.5.0-english/* /var/www/phpmyadmin/

  EOH
  not_if "test -f /var/www/phpmyadmin"
end