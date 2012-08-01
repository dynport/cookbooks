include_recipe "source"
package "libpcre3-dev"

NAME_AND_VERSION = "haproxy-1.4.21"
FILE_NAME = "#{NAME_AND_VERSION}.tar.gz"

download_file "http://haproxy.1wt.eu/download/1.4/src/#{FILE_NAME}"

DIR = "/opt/#{NAME_AND_VERSION}/sbin"

directory DIR do
  recursive true
  mode 0755
end

execute "install haproxy" do
  cwd src_dir
  command "
    tar xvfz #{FILE_NAME}
    cd #{NAME_AND_VERSION}
    make TARGET=linux26 USE_STATIC_PCRE=1 && cp ./haproxy #{DIR}/haproxy
  "
end

link "/opt/haproxy" do
  to "/opt/#{NAME_AND_VERSION}"
end

cookbook_file "/etc/init.d/haproxy" do
  source "haproxy.init"
  mode 0744
end
