def rvm_user
  node[:user] || node.rvm.user
end

def rvm_user_home
  "/home/#{rvm_user}"
end

def rvm_symlink
  "#{rvm_user_home}/.rvm"
end