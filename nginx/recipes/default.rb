INSTALL_DIR = node.source.install_dir
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

download_file "http://nginx.org/download/nginx-#{NGINX_VERSION}.tar.gz"

PATCH_PATH = "#{SRC_DIR}/syslog_1.2.0"
PATCH_FILE = "#{PATCH_PATH}/syslog_1.2.0.patch"

directory PATCH_PATH do
  recursive true
end

cookbook_file PATCH_FILE
cookbook_file "#{PATCH_PATH}/config" do
  source "syslog_patch_config"
end

execute "install nginx" do
  cwd SRC_DIR
  command "
    tar xvfz nginx-#{NGINX_VERSION}.tar.gz 
    cd nginx-#{NGINX_VERSION}
    patch -p1 < #{PATCH_FILE}
    ./configure --prefix=#{INSTALL_DIR}/nginx-#{NGINX_VERSION} --with-http_ssl_module --add-module=#{PATCH_PATH}
    make 
    make install
  "
  creates "#{INSTALL_DIR}/nginx-#{NGINX_VERSION}/sbin/nginx"
end

template "#{INSTALL_DIR}/nginx-#{NGINX_VERSION}/conf/nginx.conf" do
  source "nginx.conf.erb"
end

template "/etc/init.d/nginx" do
  source "nginx.init.erb"
  mode "0755"
end

directory "#{INSTALL_DIR}/nginx-#{NGINX_VERSION}/conf/sites-enabled" do
  recursive true
  owner NGINX_USER
  mode "0755"
end

link node.nginx.dir do
  to "#{INSTALL_DIR}/nginx-#{NGINX_VERSION}"
end
