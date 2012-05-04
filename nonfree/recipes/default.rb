template "/etc/apt/sources.list.d/non_free.list" do
  source "non_free.list"
  owner "root"
  mode "644"
  notifies :run, "execute[apt-get-update]", :immediately
end

execute "apt-get-update" do
  command "apt-get update"
  action :nothing
end