def rvm_node_and_rubies_present?
  node[:rvm] && node[:rvm][:rubies]
end

def node_rvm_user_or_node_user
  (node[:rvm] && node.rvm[:user]) || node[:user]
end

def install_rvm_ruby(user, version)
  rvm_dir = "/home/#{user}/.rvm"
  bash "install #{version} for user #{user}" do
    code ". #{rvm_dir}/scripts/rvm && rvm install #{version}"
    environment("rvm_path" => rvm_dir)
    creates "#{rvm_dir}/rubies/#{version}/bin/ruby"
    user user
  end
end

def create_rvm_gemset(rvm_user, rvm_user_home, ruby_version, gemset_name)
  script "create gemset" do
    interpreter "bash"
    user rvm_user 
    code <<-EOH
      export rvm_path=#{rvm_user_home}/.rvm
      source #{rvm_user_home}/.rvm/scripts/rvm
      rvm use #{ruby_version}
      rvm gemset create #{gemset_name}
    EOH
    creates "#{rvm_user_home}/.rvm/gems/#{ruby_version}@#{gemset_name}"
  end
end

def install_rvm(rvm_user, rvm_user_home, rvm_version=nil)
  rvm_version ||= node.rvm.version
  src_dir = "#{rvm_user_home}/src"
  rvm_dir = "#{rvm_user_home}/.rvm-#{rvm_version}"

  %w(build-essential openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev).each do |package_name|
    package package_name do
      action :install
    end
  end

  user rvm_user do
    shell "/bin/bash"
  end

  directory rvm_user_home do
    owner rvm_user
  end

  directory src_dir do
    action :create
    owner rvm_user
    recursive true
  end

  remote_file "#{src_dir}/rvm-installer" do
    source "https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer"
    mode "744"
    owner rvm_user
  end

  bash "install rvm" do
    user rvm_user
    environment("rvm_path" => rvm_dir, "HOME" => rvm_user_home)
    code %(bash #{src_dir}/rvm-installer --version #{rvm_version}; exit 0)
    creates "#{rvm_dir}/scripts/rvm"
  end

  file "/etc/profile.d/rvm.sh" do
    action :delete
  end

  file "#{rvm_user_home}/.rvmrc" do
    mode "0644"
    owner rvm_user
    content "rvm_trust_rvmrcs_flag=1"
  end

  link "#{rvm_user_home}/.rvm" do
    to rvm_dir
    not_if "test -d #{rvm_user_home}/.rvm && test ! -L #{rvm_user_home}/.rvm"
  end
end
