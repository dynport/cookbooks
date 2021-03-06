INSTALL_DIR = node.source.install_dir
SRC_DIR = "#{INSTALL_DIR}/src"
NGINX_VERSION = node.nginx.version
NGINX_USER = node.www_user

package "unzip"


packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['patch', 'pcre-devel', 'openssl-devel']},
    "default" => ['libpcre3', 'libpcre3-dev', 'libssl-dev', 'libpcrecpp0', 'zlib1g-dev', 'libgd2-xpm-dev']
)
packages.each { |pkg| package pkg }

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

remote_file "#{SRC_DIR}/headers-more-nginx-module-v0.17rc1.zip" do
  source "https://github.com/agentzh/headers-more-nginx-module/zipball/v0.17rc1"
end

cookbook_file PATCH_FILE
cookbook_file "#{PATCH_PATH}/config" do
  source "syslog_patch_config"
end

START_TIME_PATCH = "/opt/src/patches/nginx_1.0.2_start_time.diff"

directory "/opt/src/patches" do
  recursive true
end

cookbook_file "#{PATCH_PATH}/nginx_1.0.2_start_time.diff"
cookbook_file START_TIME_PATCH

execute "install nginx" do
  cwd SRC_DIR
  command "
    unzip headers-more-nginx-module-v0.17rc1.zip
    tar xvfz nginx-#{NGINX_VERSION}.tar.gz 
    cd nginx-#{NGINX_VERSION}
    patch -p1 < #{PATCH_FILE}
    patch -p0 < #{START_TIME_PATCH}
    ./configure --prefix=#{INSTALL_DIR}/nginx-#{NGINX_VERSION} --with-http_ssl_module --add-module=#{PATCH_PATH} --with-http_gzip_static_module --with-http_stub_status_module --add-module=/opt/src/agentzh-headers-more-nginx-module-3580526/
    make 
    make install
  "
  creates "#{INSTALL_DIR}/nginx-#{NGINX_VERSION}/sbin/nginx"
end

directory "/var/log/nginx" do
  recursive true
end

template "#{INSTALL_DIR}/nginx-#{NGINX_VERSION}/conf/nginx.conf"

template "/etc/init.d/nginx" do
  if platform_family?("debian")
    source "nginx.init.erb"
  elsif platform_family?("rhel")
    source "nginx.init.centos.erb"
  else
    raise "Your platform is currently unsupported"
  end
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
