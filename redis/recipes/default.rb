INSTALL_DIR = "/opt"
SRC_DIR = "#{INSTALL_DIR}/src"
REDIS_VERSION = "2.4.10"
REDIS_USER = "redis"

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

remote_file "#{SRC_DIR}/redis-#{REDIS_VERSION}.tar.gz" do
  source "http://redis.googlecode.com/files/redis-#{REDIS_VERSION}.tar.gz"
  mode "0644"
  checksum "4d34482198cec272afd45d0390d4e1f32ee847094834133613a925012810ed21"
end

execute "install redis" do
  cwd SRC_DIR
  command "tar xvfz redis-#{REDIS_VERSION}.tar.gz && cd redis-#{REDIS_VERSION} && make && make PREFIX=#{INSTALL_DIR}/redis-#{REDIS_VERSION} install"
  creates "#{INSTALL_DIR}/redis-#{REDIS_VERSION}/bin/redis-cli"
end

link "#{INSTALL_DIR}/redis" do
  to "#{INSTALL_DIR}/redis-#{REDIS_VERSION}"
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