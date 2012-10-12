include_recipe "source"

the_version  = node.percona_toolkit.version
name = "percona-toolkit-#{the_version}"

download_file "http://www.percona.com/downloads/percona-toolkit/#{the_version}/#{name}.tar.gz"
execute "install percona toolkit" do
  cwd "/opt"
  command "tar xvfz /opt/src/#{name}.tar.gz"
  not_if "test -e /opt/#{name}/pt-online-schema-change"
end

link "/opt/percona-toolkit" do
  to "/opt/#{name}"
end
