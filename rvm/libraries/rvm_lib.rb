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

def create_rvm_gemset(ruby_desc, gemset_name)
  script "create gemset" do
    interpreter "bash"
    user rvm_user 
    code <<-EOH
      export rvm_path=#{rvm_user_home}/.rvm
      source #{rvm_user_home}/.rvm/scripts/rvm
      rvm use #{ruby_desc}
      rvm gemset create #{gemset_name}
    EOH
    creates "#{rvm_user_home}/.rvm/gems/#{ruby_desc}@#{gemset_name}"
  end
end
