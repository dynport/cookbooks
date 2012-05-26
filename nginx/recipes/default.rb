INSTALL_DIR = node.nginx.install_root
SRC_DIR = "#{INSTALL_DIR}/src"
NGINX_VERSION = node.nginx.version
NGINX_USER = node.www_user

%w(libpcre3 libpcre3-dev libpcrecpp0 zlib1g-dev libssl-dev libgd2-xpm-dev).each { |pkg| package pkg }

user NGINX_USER do
  action :create
end

directory SRC_DIR do
  action :create
  recursive true
end

directory "/var/lib/nginx" do
  action :create
  recursive true
  owner NGINX_USER
end

remote_file "#{SRC_DIR}/nginx-#{NGINX_VERSION}.tar.gz" do
  source "http://nginx.org/download/nginx-#{NGINX_VERSION}.tar.gz"
  mode "0644"
end

template "#{INSTALL_DIR}/nginx-#{NGINX_VERSION}/conf/nginx.conf" do
  source "nginx.conf.erb"
end

template "/etc/init.d/nginx" do
  source "nginx.init.erb"
  mode "0755"
end

execute "install nginx" do
  cwd SRC_DIR
  command "tar xvfz nginx-#{NGINX_VERSION}.tar.gz && cd nginx-#{NGINX_VERSION} && ./configure --prefix=#{INSTALL_DIR}/nginx-#{NGINX_VERSION} && make && make install"
  creates "#{INSTALL_DIR}/nginx-#{NGINX_VERSION}/sbin/nginx"
end

link node.nginx.dir do
  to "#{INSTALL_DIR}/nginx-#{NGINX_VERSION}"
end