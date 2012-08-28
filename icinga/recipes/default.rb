include_recipe "source"
include_recipe "nagios::nrpe"
include_recipe "nagios::plugins"

version = node.icinga.version
name = "icinga-#{version}"
file_name = "#{name}.tar.gz"

package "apache2"

download_file "http://downloads.sourceforge.net/project/icinga/icinga/#{version}/#{file_name}"

user_name = "icinga"

user user_name

HTPASSWD_FILE_NAME = "/opt/#{name}/etc/htpasswd.users"

execute "install icinga" do
  cwd "/opt/src"
  command <<-EOF
  tar xvfz #{file_name}
  cd #{name}
  ./configure --prefix=/opt/#{name} --with-httpd-conf=/etc/apache2/conf.d
  make all && make install install-html install-webconf install-init install-commandmode
  EOF
  creates "/opt/#{name}/bin/icinga"
  notifies :run, "execute[reload_apache]"
end

icinga_config_dir = "/opt/#{name}/etc"

directory icinga_config_dir do
  mode "0755"
  owner user_name
  recursive true
end

directory "#{icinga_config_dir}/conf.d" do
  mode "0755"
  owner user_name
  recursive true
end

%w(hosts commands contacts services timeperiods).each do |cfg_name|
  template "#{icinga_config_dir}/conf.d/#{cfg_name}.cfg" do
    mode "0644"
    owner user_name
    notifies :run, "execute[restart_icinga]"
  end
end

%w(icinga.cfg cgi.cfg).each do |cfg_file|
  template "#{icinga_config_dir}/#{cfg_file}" do
    variables(:icinga_root => "/opt/#{name}")
    owner user_name
    mode "0644"
  end
end

execute "create htpasswd" do
  command "htpasswd -cb #{HTPASSWD_FILE_NAME} icingaadmin letmein && chown #{user_name} #{HTPASSWD_FILE_NAME}"
  creates HTPASSWD_FILE_NAME
end

group "icinga" do
  action :modify
  members "www-data"
  append true
end

file "#{icinga_config_dir}/resource.cfg" do
  content "$USER1$=/opt/nagios-plugins/libexec\n"
  owner user_name
end

link "/opt/icinga" do
  to "/opt/#{name}"
end

link "/usr/lib/cgi-bin/icinga" do
  to "/opt/icinga/sbin"
end

service "icinga" do
  action [:enable, :start]
end

execute "restart_icinga" do
  command "/etc/init.d/icinga restart"
  action :nothing
end

execute "reload_apache" do
  command "/etc/init.d/apache2 reload"
  action :nothing
end
