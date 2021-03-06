include_recipe "source"

url = node.percona_xtrabackup.download_url
file_name = File.basename(url)
name = file_name.gsub(".tar.gz", "")

name_with_major_version = name.gsub(/\-(\d+)$/, "")

download_file url

execute "install percona xtrabackup" do
  cwd "/opt"
  command "tar xvfz /opt/src/#{file_name}"
  not_if "test -e /opt/percona-xtrabackup-#{name}/bin/xtrabackup"
end

link "/opt/percona-xtrabackup" do
  to "/opt/#{name_with_major_version}"
end
