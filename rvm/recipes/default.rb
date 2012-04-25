require "pathname"
INSTALL_DIR = "/opt/local"
SRC_DIR = "#{INSTALL_DIR}/src"
USER_HOME = "/home/#{node[:user]}"

user node[:user] do
  action :create
  home USER_HOME
end

directory USER_HOME do
  action :create
  owner node[:user]
end

%w(build-essential openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev libxml2-dev libmysqlclient-dev git-core libxslt1-dev).each do |package_name|
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
  user node[:user]
  environment({ "HOME" => USER_HOME })
  code %(bash "#{SRC_DIR}/rvm-installer")
  creates "#{USER_HOME}/.rvm/bin/rvm"
end

if default_ruby = node[:rvm][:default_ruby]
  bash "set default rvm" do
    user node[:user]
    environment("rvm_path" => "#{USER_HOME}/.rvm", "HOME" => USER_HOME)
    code ". #{USER_HOME}/.rvm/scripts/rvm; { ruby -v | grep -v '#{default_ruby}' && rvm use #{default_ruby} --default; }; exit 0"
    not_if "readlink #{USER_HOME}/.rvm/rubies/default | grep #{default_ruby}"
  end
end

def install_rvm_ruby(version)
  bash "install #{version}" do
    user node[:user]
    code ". #{USER_HOME}/.rvm/scripts/rvm && rvm install #{version}"
    environment("rvm_path" => "#{USER_HOME}/.rvm")
    creates "#{USER_HOME}/.rvm/rubies/ruby-#{version}/bin/ruby"
  end
end

node[:rvm][:rubies].each do |ruby|
  install_rvm_ruby(ruby)
end