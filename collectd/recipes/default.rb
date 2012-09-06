include_recipe "source"

user "collectd"

COLLECTD_PREFIX = "collectd-#{node.collectd.version}"
COLLECTD_FILE = "#{COLLECTD_PREFIX}.tar.gz"
COLLECTD_DIR = "/opt/#{COLLECTD_PREFIX}"

%w(python-dev libperl-dev librrd-dev libdbd-mysql libyajl-dev yajl-tools libcurl4-openssl-dev libdbi0-dev).each do |name|
  package name
end

download_file "http://collectd.org/files/#{COLLECTD_FILE}"

execute "install collected" do
  command <<-CMD
    tar xvfz #{COLLECTD_FILE}
    cd #{COLLECTD_PREFIX}
    ./configure --prefix=#{COLLECTD_DIR}
    make
    make install
  CMD
  creates "#{COLLECTD_DIR}/sbin/collectd"
  cwd src_dir
end

link "/opt/collectd" do
  to COLLECTD_DIR
end

template "/etc/init.d/collectd" do
  source "collectd-start-stop.erb"
  mode "0755"
end

PYHTON_DIR = "/opt/collectd/lib/collectd/plugins/python"

directory PYHTON_DIR do
  recursive true
  mode "0755"
end

%w(solr_info redis_info resque_info redis_client).each do |file|
  cookbook_file "/opt/collectd/lib/collectd/plugins/python/#{file}.py" do
    mode "0644"
    owner "collectd"
  end
end


template "/etc/collectd.conf" do
  source "collectd.conf.erb"
  variables(
    "memcached_address" => node.collectd[:memcached_address],
    "memcached_port" => node.collectd[:memcached_port],
    "graphite_address" => node.collectd[:graphite_address],
    "graphite_port" => node.collectd[:graphite_port],
    "mount_points" => node.collectd[:mount_points],
    "processes" => node.collectd[:processes],
    "nginx_url" => node.collectd[:nginx_url]
  )
  owner "collectd"
  mode "0644"
  notifies :run, 'execute[start_or_restart_collectd]'
end

execute "start_or_restart_collectd" do
  command %(/etc/init.d/collectd status | grep running > /dev/null && /etc/init.d/collectd restart || /etc/init.d/collectd start)
  action :nothing
end

service "collectd" do
  action [ :enable, :start ]
end
