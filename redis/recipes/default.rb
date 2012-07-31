INSTALL_DIR = node.source.install_dir
SRC_DIR = "#{INSTALL_DIR}/src"
REDIS_VERSION = node.redis.version
REDIS_USER = node.redis.user

user REDIS_USER do
  action :create
end

directory SRC_DIR do
  action :create
  recursive true
end

directory "/var/lib/redis" do
  action :create
  recursive true
  owner REDIS_USER
end

download_file "http://redis.googlecode.com/files/redis-#{REDIS_VERSION}.tar.gz"

execute "install redis" do
  cwd SRC_DIR
  command "tar xvfz redis-#{REDIS_VERSION}.tar.gz && cd redis-#{REDIS_VERSION} && make && make PREFIX=#{INSTALL_DIR}/redis-#{REDIS_VERSION} install"
  creates "#{INSTALL_DIR}/redis-#{REDIS_VERSION}/bin/redis-cli"
end

link "#{INSTALL_DIR}/redis" do
  to "#{INSTALL_DIR}/redis-#{REDIS_VERSION}"
end

directory "/data/redis" do
  recursive true
  owner REDIS_USER
end

template "/etc/redis.conf" do
  source "redis.conf.erb"
  mode 0644
  owner REDIS_USER
  group REDIS_USER
end

template "/etc/init.d/redis-server" do
  source "redis-server.erb"
  mode 0744
  owner REDIS_USER
  group REDIS_USER
end
