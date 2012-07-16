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

user USER do
  shell "/bin/bash"
end

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
  environment("rvm_path" => RVM_DIR, "HOME" => USER_HOME)
  code %(bash #{SRC_DIR}/rvm-installer --version #{RVM_VERSION})
  creates "#{RVM_DIR}/scripts/rvm"
end

file "/etc/profile.d/rvm.sh" do
  action :delete
end

template "#{rvm_user_home}/.rvmrc" do
  mode "0644"
  owner USER
end

link rvm_symlink do
  to RVM_DIR
  not_if "test -d #{USER_HOME}/.rvm && test ! -L #{USER_HOME}/.rvm"
end
