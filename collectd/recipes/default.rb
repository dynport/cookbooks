include_recipe "source"

CREDIS_PREFIX = "credis-0.2.3"
CREDIS_FILE = "#{CREDIS_PREFIX}.tar.gz"
CREDIS_DIR = "/opt/#{CREDIS_PREFIX}"

COLLECTD_PREFIX = "collectd-5.1.0"
COLLECTD_FILE = "#{COLLECTD_PREFIX}.tar.gz"
COLLECTD_DIR = "/opt/#{COLLECTD_PREFIX}"

%w(python-dev libperl-dev librrd-dev).each do |name|
  package name
end

download_file "http://credis.googlecode.com/files/#{CREDIS_FILE}"
download_file "http://collectd.org/files/#{COLLECTD_FILE}"

%w(lib include).each do |dir|
  directory "#{CREDIS_DIR}/#{dir}" do
    recursive true
    mode 0755
  end
end

link "/opt/credis" do
  to CREDIS_DIR
end

execute "install credis" do
  command <<-CMD
    tar xvfz #{CREDIS_FILE}
    cd #{CREDIS_PREFIX}
    make
    cp *.h #{CREDIS_DIR}/include
    cp *.o *.a *.so #{CREDIS_DIR}/lib
    cp *.o *.a *.so /lib
  CMD
  cwd src_dir
  creates "#{CREDIS_DIR}/lib/credis.o"
end

execute "install collected" do
  command <<-CMD
    tar xvfz #{COLLECTD_FILE}
    cd #{COLLECTD_PREFIX}
    ./configure --prefix=#{COLLECTD_DIR} --with-libcredis=/opt/credis
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

template "/etc/collectd.conf" do
  source "collectd.conf.erb"
  variables(
    "redis" => node.collectd[:redis],
    "memcached" => node.collectd[:memcached],
    "graphite" => node.collectd[:graphite],
    "mount_points" => node.collectd[:mount_points]
  )
end
