include_recipe "rvm"

user node.user do
  action :create
end

group "rvm" do
  members [node.user]
end