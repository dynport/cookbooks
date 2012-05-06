require "pathname"
INSTALL_DIR = "/opt"
SRC_DIR = "#{INSTALL_DIR}/src"
RVM_PATH = "/opt/rvm"

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
  environment("rvm_path" => RVM_PATH)
  code %(bash "#{SRC_DIR}/rvm-installer")
  creates "#{RVM_PATH}/scripts/rvm"
end

file "/etc/profile.d/rvm.sh" do
  action :delete
end

# if default_ruby = node[:rvm][:default_ruby]
#   bash "set default rvm" do
#     environment("rvm_path" => "#{USER_HOME}/.rvm", "HOME" => USER_HOME)
#     code ". #{USER_HOME}/.rvm/scripts/rvm; { ruby -v | grep -v '#{default_ruby}' && rvm use #{default_ruby} --default; }; exit 0"
#     not_if "readlink #{USER_HOME}/.rvm/rubies/default | grep #{default_ruby}"
#   end
# end

def install_rvm_ruby(version)
  bash "install #{version}" do
    code ". #{RVM_PATH}/scripts/rvm && rvm install #{version}"
    environment("rvm_path" => RVM_PATH)
    creates "#{RVM_PATH}/rubies/ruby-#{version}/bin/ruby"
  end
end

if node[:rvm] && node[:rvm][:rubies]
  node.rvm.rubies.each do |ruby|
    install_rvm_ruby(ruby)
  end
end