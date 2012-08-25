require "pathname"
rvm_user = node[:user] || node.rvm.user
rvm_user_home = "/home/#{rvm_user}"
rvm_version = node.rvm.version

if rvm_user
  install_rvm(rvm_user, rvm_user_home, rvm_version)
end
