require "pathname"
INSTALL_DIR = "/opt"
SRC_DIR = "#{INSTALL_DIR}/src"
RVM_VERSION = node.rvm.version
RVM_DIR = "/opt/rvm-#{RVM_VERSION}"

# libxml2-dev libmysqlclient-dev git-core libxslt1-dev
%w(build-essential openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev).each do |package_name|
  package package_name do
    action :install
  end
end

directory SRC_DIR do
  action :create
  recursive true
end

remote_file "#{SRC_DIR}/rvm-installer" do
  source "https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer"
  mode "744"
end

bash "install rvm" do
  environment("rvm_path" => RVM_DIR)
  code %(bash #{SRC_DIR}/rvm-installer --version #{RVM_VERSION})
  creates "#{RVM_DIR}/scripts/rvm"
end

file "/etc/profile.d/rvm.sh" do
  action :delete
end

def install_rvm_ruby(version)
  bash "install #{version}" do
    code ". #{RVM_DIR}/scripts/rvm && rvm install #{version}"
    environment("rvm_path" => RVM_DIR)
    creates "#{RVM_DIR}/rubies/#{version}/bin/ruby"
  end
end

link "#{INSTALL_DIR}/rvm" do
  to RVM_DIR
end

if node[:rvm] && node[:rvm][:rubies]
  node.rvm.rubies.each do |ruby|
    install_rvm_ruby(ruby)
  end
end