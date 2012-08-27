include_recipe "source"
include_recipe "nagios::plugins"

package "build-essential"
package "libssl-dev"

version = "2.13"
name = "nrpe-#{version}"
file_name = "#{name}.tar.gz"

download_file "http://prdownloads.sourceforge.net/sourceforge/nagios/#{file_name}"

SRC_DIR = node.source.install_dir + "/src"

user "nagios"

execute "install nrpe" do
  cwd SRC_DIR
  command "
    tar xvfz #{file_name} && cd #{name} && ./configure --enable-command-args --prefix=/opt/#{name} && make all && make install-plugin install-daemon install-daemon-config && cp /opt/src/#{name}/init-script.debian /etc/init.d/nrpe && chmod 755 /etc/init.d/nrpe
  "
  creates "/opt/#{name}/bin/nrpe"
end

link "/opt/nrpe" do
  to "/opt/#{name}"
end

directory "/opt/#{name}/etc" do
  recursive true
end

template "/opt/#{name}/etc/nrpe.cfg"

template "/etc/init.d/nrpe" do
  mode "0755"
  source "nrpe-init-script.erb"
end
