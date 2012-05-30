INSTALL_DIR = node.source.install_dir
SRC_DIR = "#{INSTALL_DIR}/src"
MEMCACHED_VERSION = node.memcached.version
MEMCACHED_USER = node.memcached.user
MEMCACHED_DIR = "#{INSTALL_DIR}/memcached-#{MEMCACHED_VERSION}"

package "libevent-dev" do
  action :install
end

user MEMCACHED_USER do
  action :create
end

directory SRC_DIR do
  action :create
  recursive true
end

download_file "http://memcached.googlecode.com/files/memcached-#{MEMCACHED_VERSION}.tar.gz"

execute "install memcached" do
  cwd SRC_DIR
  command "tar xvfz memcached-#{MEMCACHED_VERSION}.tar.gz && cd memcached-#{MEMCACHED_VERSION} && ./configure --prefix=#{MEMCACHED_DIR} && make && make install"
  creates "#{MEMCACHED_DIR}/bin/memcached"
end

link "#{INSTALL_DIR}/memcached" do
  to MEMCACHED_DIR
end

template "/etc/memcached.conf" do
  source "memcached.conf.erb"
  mode 0644
  owner MEMCACHED_USER
  group MEMCACHED_USER
end

template "#{MEMCACHED_DIR}/bin/start-memcached" do
  source "start-memcached.erb"
  mode 0744
  owner MEMCACHED_USER
  group MEMCACHED_USER
end

template "/etc/init.d/memcached" do
  source "memcached.erb"
  mode 0744
  owner MEMCACHED_USER
  group MEMCACHED_USER
end