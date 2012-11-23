include_recipe "source"
include_recipe "nagios::plugins"

packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['openssl-devel']},
    "default" => ['build-essential','libssl-dev']
)
packages.each { |pkg| package pkg }

user "icinga"

version = "2.13"
name = "nrpe-#{version}"
file_name = "#{name}.tar.gz"

download_file "http://prdownloads.sourceforge.net/sourceforge/nagios/#{file_name}"

SRC_DIR = node.source.install_dir + "/src"

user "nagios"

execute "install nrpe" do
  cwd SRC_DIR

  init_script = if platform_family?("debian")
    "init-script.debian"
  else
    "init-script"
  end

  command "
    tar xvfz #{file_name} && cd #{name} && ./configure --enable-command-args --prefix=/opt/#{name} && make all && make install-plugin install-daemon install-daemon-config && cp /opt/src/#{name}/#{init_script} /etc/init.d/nrpe && chmod 755 /etc/init.d/nrpe
  "
  creates "/opt/#{name}/bin/nrpe"
end

link "/opt/nrpe" do
  to "/opt/#{name}"
end

["/opt/#{name}/etc", "/opt/#{name}/var", "/opt/#{name}/var/run"].each do |dir|
   directory dir do
    recursive true
    owner "icinga"
    mode "0755"
  end
end

template "/opt/#{name}/etc/nrpe.cfg" do
  notifies :restart, "service[nrpe]"
  owner "icinga"
  mode "0644"
end

service "nrpe" do
  action [:enable, :start]
end
