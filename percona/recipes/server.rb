include_recipe "source"
package "libaio1"

url = node.percona.download_url
file_name = File.basename(url)
name = file_name.gsub(".tar.gz", "")

download_file url

group "mysql"

user "mysql" do
  group "mysql"
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
  owner "mysql"
  mode "0755"
  recursive true
end

directory "/etc/mysql" do
  mode "0755"
  owner "mysql"
end

template "/etc/mysql/my.cnf" do
  mode "0644"
  owner "mysql"
end

template "/etc/init.d/mysql" do
  source "mysql_start_stop"
  mode "0755"
end

execute "mysql_install_db" do
  cwd "/opt/percona"
  command "./scripts/mysql_install_db"
  not_if "test -e #{data_dir}/mysql"
end

