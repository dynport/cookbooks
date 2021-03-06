include_recipe "source"

packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['openssl-devel']},
    "default" => ['libssl-dev']
)
packages.each { |pkg| package pkg }

version = node.nagios.plugins.version
name = "nagios-plugins-#{version}"
file_name = "#{name}.tar.gz"

download_file "http://downloads.sourceforge.net/project/nagiosplug/nagiosplug/#{version}/#{file_name}"

execute "install nagios plugins" do
  cwd "/opt/src"
  command <<-EOF
    tar xvfz #{file_name}
    cd #{name}
    ./configure --prefix=/opt/#{name} && make && make install
  EOF
  creates "/opt/#{name}/libexec/check_load"
end

link "/opt/nagios-plugins" do
  to "/opt/#{name}"
end
