include_recipe "source"

the_version  = node.percona_toolkit.version

download_file "http://www.percona.com/downloads/percona-toolkit/LATEST/percona-toolkit-#{the_version}.tar.gz"
execute "install percona toolkit" do
  cwd "/opt"
  command "tar xvfz /opt/src/percona-toolkit-#{the_version}.tar.gz"
  not_if "test -e /opt/percona-toolkit-#{the_version}/pt-online-schema-change"
end

link "/opt/percona-toolkit" do
  to "/opt/percona-toolkit-#{the_version}"
end
