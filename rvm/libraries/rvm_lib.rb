def rvm_user
  node[:user] || node.rvm.user
end

def rvm_user_home
  "/home/#{rvm_user}"
end

def rvm_symlink
  "#{rvm_user_home}/.rvm"
end

def rvm_dir
  "#{rvm_user_home}/.rvm-#{node.rvm.version}"
end

def install_rvm_ruby(version)
  bash "install #{version}" do
    code ". #{rvm_dir}/scripts/rvm && rvm install #{version}"
    environment("rvm_path" => rvm_dir)
    creates "#{rvm_dir}/rubies/#{version}/bin/ruby"
    user rvm_user
  end
end