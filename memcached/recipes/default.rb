# http://memcached.googlecode.com/files/memcached-1.4.13.tar.gz

INSTALL_DIR = "/opt"
SRC_DIR = "#{INSTALL_DIR}/src"
REDIS_VERSION = "1.4.13"
REDIS_USER = "memcached"

user REDIS_USER do
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
  command "tar xvfz memcached-#{MEMCACHED_VERSION}.tar.gz && cd memcached-#{MEMCACHED_VERSION} && ./configure --prefix=#{INSTALL_DIR}/memcached-#{MEMCACHED_VERSION} && make && make install"
  creates "#{INSTALL_DIR}/memcached-#{MEMCACHED_VERSION}/bin/memcached"
end

link "#{INSTALL_DIR}/memcached" do
  to "#{INSTALL_DIR}/memcached-#{REDIS_VERSION}"
end

# service "memcached" do
#   supports :status => true, :restart => true
#   action [ :enable, :start ]
# end