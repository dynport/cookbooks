include_recipe "source"

package "libxslt-dev"
package "libxml2-dev"
package "python-dev"
package "libreadline-dev"
package "bison"

version = node.postgres.version
version_name = "postgresql-#{version}"

download_file "http://ftp.postgresql.org/pub/source/v#{version}/#{version_name}.tar.bz2"

execute "install postgres" do
  cwd "/opt/src"
  command "tar xvfj #{version_name}.tar.bz2 && cd #{version_name} && ./configure --prefix=/opt/#{version_name} --with-libxml --with-python --with-libxslt --with-openssl && make && make install"
  not_if "test -e /opt/#{version_name}/bin/postmaster"
end


user "postgres"

template "/etc/init.d/postgresql" do
  source "postgresql.start-stop"
  mode "0755"
end

link "/opt/postgresql" do
  to "/opt/#{version_name}"
end

directory node.postgres.data_dir do
  owner "postgres"
  recursive true
end

execute "init data dir" do
  user "postgres"
  command "/opt/#{version_name}/bin/pg_ctl init -D #{node.postgres.data_dir}"

  environment("LC_ALL" => "en_US.UTF-8")

  not_if "test -e #{node.postgres.data_dir}/postgresql.conf"
end

