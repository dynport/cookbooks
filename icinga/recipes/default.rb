include_recipe "source"
include_recipe "nagios::nrpe"
include_recipe "nagios::plugins"

package "apache2"
package "libgd2-xpm-dev"

icinga = Icinga.new(self)

download_file "http://downloads.sourceforge.net/project/icinga/icinga/#{icinga.version}/#{icinga.file_name}"

user icinga.username

HTPASSWD_FILE_NAME = "#{icinga.etc_dir}/htpasswd.users"

execute "install icinga" do
  cwd "/opt/src"
  command <<-EOF
  tar xvfz #{icinga.file_name}
  cd #{icinga.name}
  ./configure --prefix=#{icinga.dir} --with-httpd-conf=/etc/apache2/conf.d
  make all && make install install-html install-webconf install-init install-commandmode
  EOF
  creates "#{icinga.dir}/bin/icinga"
  notifies :run, "execute[reload_apache]"
end

icinga.create_all_dirs!

%w(templates hosts commands contacts services timeperiods).each do |cfg_name|
  icinga.write_config(cfg_name)
end

%w(icinga.cfg cgi.cfg).each do |cfg_file|
  template "#{icinga.etc_dir}/#{cfg_file}" do
    variables(:icinga_root => icinga.dir)
    owner icinga.username
    mode "0644"
  end
end

execute "create htpasswd" do
  command "htpasswd -cb #{HTPASSWD_FILE_NAME} icingaadmin #{icinga.password} && chown #{icinga.username} #{HTPASSWD_FILE_NAME}"
  creates HTPASSWD_FILE_NAME
end

group "icinga" do
  action :modify
  members "www-data"
  append true
end

file "#{icinga.etc_dir}/resource.cfg" do
  content "$USER1$=/opt/nagios-plugins/libexec\n"
  owner icinga.username
end

link "/opt/icinga" do
  to icinga.dir
end

link "/usr/lib/cgi-bin/icinga" do
  to "/opt/icinga/sbin"
end

service "icinga" do
  action [:enable, :start]
end

execute "reload_apache" do
  command "/etc/init.d/apache2 reload"
  action :nothing
end
