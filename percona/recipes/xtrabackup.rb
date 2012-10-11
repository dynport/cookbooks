include_recipe "source"

the_version = node.percona_xtrabackup.version
the_name = "percona-xtrabackup-#{the_version}-#{node.percona_xtrabackup.patchlevel}"

download_file "http://www.percona.com/downloads/XtraBackup/LATEST/binary/Linux/x86_64/#{the_name}.tar.gz"

execute "install percona xtrabackup" do
  cwd "/opt"
  command "tar xvfz /opt/src/#{the_name}.tar.gz"
  not_if "test -e /opt/percona-xtrabackup-#{the_name}/bin/xtrabackup"
end

link "/opt/percona-xtrabackup" do
  to "/opt/percona-xtrabackup-#{the_version}"
end
