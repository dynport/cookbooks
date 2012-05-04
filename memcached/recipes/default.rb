# http://memcached.googlecode.com/files/memcached-1.4.13.tar.gz

INSTALL_DIR = "/opt"
SRC_DIR = "#{INSTALL_DIR}/src"
MEMCACHED_VERSION = "1.4.13"
MEMCACHED_USER = "memcached"
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

remote_file "#{SRC_DIR}/memcached-#{MEMCACHED_VERSION}.tar.gz" do
  source "http://memcached.googlecode.com/files/memcached-#{MEMCACHED_VERSION}.tar.gz"
  mode "0644"
  checksum "cb0b8b87aa57890d2327906a11f2f1b61b8d870c0885b54c61ca46f954f27e29"
end

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