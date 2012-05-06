include_recipe "rvm"

user node.user do
  action :create
  shell "/bin/bash"
  home "/home/#{node.user}"
end

group "rvm" do
  members [node.user]
end

["/home/#{node.user}", "/home/#{node.user}/.profile.d"].each do |path|
  directory path do
    owner node.user
    mode "0755"
  end
end

template "/home/#{node.user}/.profile" do
  source "profile.erb"
  owner node.user
  mode "644"
end

template "/home/#{node.user}/.profile.d/rvm" do
  source "rvm.profile.erb"
  owner node.user
  mode "644"
end