require "pathname"
USER = rvm_user
USER_HOME = rvm_user_home
SRC_DIR = "#{USER_HOME}/src"
RVM_VERSION = node.rvm.version
RVM_DIR = "#{USER_HOME}/.rvm-#{RVM_VERSION}"

%w(build-essential openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev).each do |package_name|
  package package_name do
    action :install
  end
end

user USER
directory USER_HOME do
  owner USER
end

directory SRC_DIR do
  action :create
  owner USER
  recursive true
end

remote_file "#{SRC_DIR}/rvm-installer" do
  source "https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer"
  mode "744"
  owner USER
end

bash "install rvm" do
  user USER
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

link rvm_symlink do
  to RVM_DIR
  not_if "test -d #{USER_HOME}/.rvm && test ! -L #{USER_HOME}/.rvm"
  owner USER
end

if node[:rvm] && node[:rvm][:rubies]
  node.rvm.rubies.each do |ruby|
    install_rvm_ruby(ruby)
  end
end