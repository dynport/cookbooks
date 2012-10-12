include_recipe "source"
package "libaio1"

url = node.percona.download_url
file_name = File.basename(url)
name = file_name.gsub(".tar.gz", "")

download_file url

group "percona"

user "percona" do
  group "percona"
end

execute "install percona server" do
  cwd "/opt"
  command "tar xvfz /opt/src/#{file_name}"
  creates "/opt/#{name}/bin/mysqld"
end

link "/opt/percona" do
  to "/opt/#{name}"
end

data_dir = node.mysql.datadir

directory data_dir do
  owner "percona"
  mode "0755"
  recursive true
end

directory "/etc/percona-server" do
  mode "0755"
  owner "percona"
end

defaults_file = "/etc/percona-server/my.cnf"

template defaults_file do
  mode "0644"
  owner "percona"
end

template "/etc/init.d/percona-server" do
  source "percona_start_stop.erb"
  mode "0755"
  variables(:defaults_file => defaults_file)
end

execute "mysql_install_db" do
  cwd "/opt/percona"
  command "./scripts/mysql_install_db --defaults-file=#{defaults_file}"
  not_if "test -e #{data_dir}/mysql"
end

link "/root/.my.cnf" do
  to defaults_file
end
